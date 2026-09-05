package org.openmrs.module.mambacore.api.dao.impl;

import org.openmrs.module.mambacore.api.dao.FlattenDatabaseDao;
import org.openmrs.module.mambacore.db.ConnectionPoolManager;
import org.openmrs.module.mambacore.util.MambaETLProperties;
import org.openmrs.module.mambacore.util.StringReplacerUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class JdbcFlattenDatabaseDao implements FlattenDatabaseDao {

    private static final Logger log = LoggerFactory.getLogger(JdbcFlattenDatabaseDao.class);

    private static final String ETL_DEPLOY_SQL = "mamba/jdbc_create_stored_procedures.sql";
    private static final String DELIMITER = "~-~-";

    private static final String SOURCE_DB_CHARSET_QUERY =
        "SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM information_schema.SCHEMATA "
            + "WHERE SCHEMA_NAME = ?";

    private static final String DATABASE_EXISTS_QUERY =
        "SELECT 1 FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = ?";

    @Override
    public void deployMambaEtl() {

        MambaETLProperties props = MambaETLProperties.getInstance();
        log.info("Deploying MambaETL, scheduled @interval: " + props.getInterval() + " seconds...");

        try {
            if (props.isUseExternalEtl()) {
                // External mode: Auto-discover and deploy all SQL files in the external directory
                try {
                    deployFromExternalDirectory(props);
                } catch (IOException e) {
                    log.error("Failed to deploy ETL from external directory: {}", props.getEtlDirectoryPath(), e);
                    // Fall back to internal mode on external failure
                    log.warn("Falling back to internal mode due to external directory failure");
                    deployFromClasspath(props);
                }
            } else {
                // Internal mode: Use the default classpath resource
                deployFromClasspath(props);
            }
            log.info("Done deploying MambaETL...");
        } catch (RuntimeException e) {
            log.error("Failed to deploy MambaETL", e);
            throw e;
        }
    }

    private void deployFromClasspath(MambaETLProperties props) {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        try (InputStream stream = classLoader.getResourceAsStream(ETL_DEPLOY_SQL)) {

            if (stream == null) {
                log.error("SQL script not found in classpath: {}", ETL_DEPLOY_SQL);
                throw new RuntimeException("SQL script not found in classpath: " + ETL_DEPLOY_SQL);
            }

            log.info("Loading ETL script from classpath resource: {}", ETL_DEPLOY_SQL);
            executeSqlScript(stream, props, false);
        } catch (IOException e) {
            log.error("IOException while reading classpath script", e);
            throw new RuntimeException("Failed to deploy ETL from classpath", e);
        }
    }

    private void deployFromExternalDirectory(MambaETLProperties props) throws IOException {
        String etlDirectoryPath = props.getEtlDirectoryPath();
        log.info("External ETL mode enabled, scanning directory: {}", etlDirectoryPath);

        // Discover all SQL files in the external directory
        List<Path> sqlFiles = discoverSqlFiles(etlDirectoryPath, props);

        if (sqlFiles.isEmpty()) {
            log.warn("No SQL files found in external directory: {}, falling back to internal mode", etlDirectoryPath);
            throw new IOException("No SQL files found in external ETL directory: " + etlDirectoryPath);
        }

        log.info("Found {} SQL file(s) in external directory", sqlFiles.size());

        // External files carry no "CREATE DATABASE / USE" prologue, unlike the bundled script. Create the
        // ETL database once, with the source database's charset and collation, then pin every script
        // execution to it.
        ensureEtlDatabaseExists(props);

        // Deploy each SQL file; the deployment stops at the first file that fails, so no further
        // scripts run against a partially deployed ETL database and the error surfaces with the
        // file that caused it.
        for (Path sqlFile : sqlFiles) {
            log.info("Deploying ETL script: {}", sqlFile.getFileName());
            try (InputStream stream = Files.newInputStream(sqlFile)) {
                executeSqlScript(stream, props, true);
            } catch (IOException | RuntimeException e) {
                // Rethrow as RuntimeException on purpose: deployMambaEtl falls back to the bundled
                // script on IOException, which must not happen once external files have already been
                // applied. Only discovery-level failures (missing/empty/unreadable directory) may
                // trigger that fallback.
                throw new RuntimeException("External ETL deployment stopped: failed to deploy "
                    + sqlFile, e);
            }
        }

        log.info("External ETL deployment completed successfully: {} file(s) applied", sqlFiles.size());
    }

    private List<Path> discoverSqlFiles(String directoryPath, MambaETLProperties props) throws IOException {
        return discoverSqlFiles(directoryPath, props.getEtlDiscoveryDepth());
    }

    /**
     * Discovers SQL files below {@code directoryPath}, deterministically sorted, up to {@code maxDepth}
     * levels deep. A missing or non-directory path yields an empty list; genuine IO failures are thrown so
     * that the caller can fall back to the bundled script.
     *
     * @param maxDepth maximum directory depth to visit, clamped to a minimum of 1 (depth 0 can never match
     *                 a file, and negative values make {@link Files#walk} throw)
     */
    static List<Path> discoverSqlFiles(String directoryPath, int maxDepth) throws IOException {
        List<Path> sqlFiles = new ArrayList<>();
        Path directory = Paths.get(directoryPath);

        if (!Files.exists(directory) || !Files.isDirectory(directory)) {
            log.warn("External ETL directory does not exist or is not a directory: {}", directoryPath);
            return sqlFiles;
        }

        int effectiveDepth = Math.max(1, maxDepth);
        if (effectiveDepth != maxDepth) {
            log.warn("Configured ETL discovery depth {} is not usable, using {} instead", maxDepth, effectiveDepth);
        }

        // Files.walk does not follow symlinks unless FOLLOW_LINKS is requested, so directory cycles cannot
        // be traversed and need no FileSystemLoopException handling. The stream is closed so an abandoned
        // walk cannot leak file descriptors, and sorting gives the deployment a defined file order.
        try (Stream<Path> paths = Files.walk(directory, effectiveDepth)) {
            paths.filter(Files::isRegularFile)
                    .filter(path -> path.toString().toLowerCase(Locale.ROOT).endsWith(".sql"))
                    .sorted()
                    .forEach(sqlFiles::add);
        }

        return sqlFiles;
    }

    /**
     * Creates the ETL database when it does not exist yet, using the default charset and collation of the
     * source (OpenMRS) database, mirroring the prologue that compile-mysql.sh prepends to the bundled
     * script. Only called for external ETL directories: the bundled script carries its own prologue, which
     * must remain authoritative in bundled mode.
     */
    private void ensureEtlDatabaseExists(MambaETLProperties props) {
        String sourceDatabase = props.getOpenmrsDatabase();
        String etlDatabase = props.getEtlDatababase();

        try (Connection connection = ConnectionPoolManager.getInstance().getDefaultDataSource().getConnection()) {

            if (databaseExists(connection, etlDatabase)) {
                log.info("ETL database '{}' already exists, skipping creation", etlDatabase);
                return;
            }

            String charset = "utf8mb4";
            String collation = "utf8mb4_unicode_ci";
            try (PreparedStatement statement = connection.prepareStatement(SOURCE_DB_CHARSET_QUERY)) {
                statement.setString(1, sourceDatabase);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        String foundCharset = resultSet.getString(1);
                        String foundCollation = resultSet.getString(2);
                        if (foundCharset == null || foundCharset.trim().isEmpty()
                                || foundCollation == null || foundCollation.trim().isEmpty()) {
                            log.warn("Source database '{}' reported no default charset/collation; creating ETL "
                                + "database '{}' with {} / {}", sourceDatabase, etlDatabase, charset, collation);
                        } else {
                            charset = foundCharset;
                            collation = foundCollation;
                        }
                    } else {
                        log.warn("Source database '{}' was not found in information_schema.SCHEMATA; creating ETL "
                            + "database '{}' with {} / {}", sourceDatabase, etlDatabase, charset, collation);
                    }
                }
            }

            // CREATE DATABASE cannot be parameterized in a PreparedStatement, so the identifier is quoted
            // explicitly; charset and collation come from information_schema, i.e. they are server-provided
            // identifiers, not user input.
            String createDatabaseSql = "CREATE DATABASE IF NOT EXISTS " + quoteIdentifier(etlDatabase)
                + " CHARACTER SET " + charset
                + " COLLATE " + collation;
            try (Statement statement = connection.createStatement()) {
                statement.execute(createDatabaseSql);
            }
            log.info("Created ETL database '{}' with charset {} and collation {}", etlDatabase, charset, collation);
        } catch (SQLException e) {
            // Deliberately no fallback to the bundled script here: a database that cannot be inspected or
            // created is a configuration problem, and silently deploying the bundled script instead would
            // replace the external deployment with the wrong content.
            throw new RuntimeException("Failed to ensure ETL database '" + etlDatabase + "' exists", e);
        }
    }

    private boolean databaseExists(Connection connection, String databaseName) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(DATABASE_EXISTS_QUERY)) {
            statement.setString(1, databaseName);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private static String quoteIdentifier(String identifier) {
        return "`" + identifier.replace("`", "``") + "`";
    }

    private void executeSqlScript(InputStream stream, MambaETLProperties props, boolean pinCatalogToEtlDatabase) {
        try {
            Map<String, String> replacements = new HashMap<>();
            replacements.put("mamba_source_db", props.getOpenmrsDatabase());
            replacements.put("mamba_etl_db", props.getEtlDatababase());

            Path modifiedEtlSqlFile = StringReplacerUtil.replaceStrings(stream, replacements);

            try (BufferedReader reader = Files.newBufferedReader(modifiedEtlSqlFile, StandardCharsets.UTF_8)) {
                // SQL comments are deliberately not stripped here: the previous regex also removed
                // "--" sequences inside string literals and corrupted valid statements (reverted in
                // c6112b1 for exactly that reason). The database server parses comments correctly.
                String sqlScript = reader.lines()
                        .collect(Collectors.joining("\n"));

                DataSource dataSource = ConnectionPoolManager
                        .getInstance()
                        .getDefaultDataSource();

                try (Connection connection = dataSource.getConnection()) {
                    // Disable auto-commit to manage transaction explicitly
                    boolean originalAutoCommit;
                    String originalCatalog = null;
                    boolean catalogPinned = false;
                    try {
                        originalAutoCommit = connection.getAutoCommit();
                        connection.setAutoCommit(false);

                        if (pinCatalogToEtlDatabase) {
                            // External SQL files have no "USE" of their own, so pin this connection to the
                            // ETL database for the duration of the script. "USE" does not implicitly
                            // commit, so this is safe inside the explicit transaction. DBCP2 does not
                            // reset the catalog when a connection is returned, hence the restore in the
                            // finally block below.
                            originalCatalog = connection.getCatalog();
                            connection.setCatalog(props.getEtlDatababase());
                            if (!props.getEtlDatababase().equalsIgnoreCase(connection.getCatalog())) {
                                throw new SQLException("Failed to switch connection to database '"
                                    + props.getEtlDatababase() + "', current database is '"
                                    + connection.getCatalog() + "'");
                            }
                            catalogPinned = true;
                        }
                    } catch (SQLException e) {
                        log.error("Failed to configure connection transaction/catalog", e);
                        throw new RuntimeException("Failed to configure connection for SQL execution", e);
                    }

                    SQLException executionError = null;
                    try {
                        executeStatements(connection, sqlScript, props);
                        connection.commit();
                        log.info("SQL script executed successfully");
                    } catch (SQLException e) {
                        executionError = e;
                        log.error("SQLException while executing script. The script contains DDL, which the "
                            + "database commits implicitly, so statements that already ran cannot be rolled "
                            + "back; re-running the ETL deployment is the recovery path since the scripts are "
                            + "idempotent", e);
                        // Attempt rollback: it undoes uncommitted DML, but DDL already applied stays
                        try {
                            connection.rollback();
                        } catch (SQLException rollbackEx) {
                            log.warn("Rollback failed after SQL execution error: {}", rollbackEx.getMessage(), rollbackEx);
                        }
                        throw new RuntimeException("SQL execution failed: DDL statements already applied cannot "
                            + "be rolled back, re-run the ETL deployment to resume", executionError);
                    } finally {
                        // Restore the catalog first: it is the one piece of connection state the pool does
                        // not reset when the connection is returned.
                        if (catalogPinned) {
                            try {
                                if (originalCatalog != null) {
                                    connection.setCatalog(originalCatalog);
                                } else {
                                    log.warn("Original catalog of the pooled connection was null; returning it "
                                        + "while still attached to '{}'", props.getEtlDatababase());
                                }
                            } catch (SQLException e) {
                                log.error("Failed to restore original catalog '{}' on the pooled connection; "
                                    + "subsequent borrowers will start on '{}'", originalCatalog,
                                    props.getEtlDatababase(), e);
                            }
                        }
                        // Restore auto-commit, don't let exceptions here suppress the original error
                        try {
                            connection.setAutoCommit(originalAutoCommit);
                        } catch (SQLException e) {
                            log.warn("Failed to restore auto-commit state", e);
                        }
                    }
                } catch (SQLException e) {
                    log.error("SQLException while obtaining database connection", e);
                    throw new RuntimeException("Failed to establish database connection for transaction", e);
                }
            } catch (IOException e) {
                log.error("Failed to read temporary SQL file: {}", modifiedEtlSqlFile, e);
                throw new RuntimeException("Failed to read temporary SQL file", e);
            } finally {
                try {
                    Files.deleteIfExists(modifiedEtlSqlFile);
                } catch (IOException e) {
                    log.warn("Failed to delete temporary file: {}", modifiedEtlSqlFile, e);
                }
            }
        } catch (IOException e) {
            log.error("IOException while reading script", e);
            throw new RuntimeException("Failed to execute SQL script", e);
        }
    }

    private void executeStatements(Connection connection, String sqlScript, MambaETLProperties props) throws SQLException {

        String[] sqlStatements = sqlScript.split(DELIMITER);

        for (String sql : sqlStatements) {
            if (sql.trim().isEmpty()) {
                continue;
            }

            try (PreparedStatement statement = connection.prepareStatement(connection.nativeSQL(sql.trim()))) {
                if (props != null && sql.contains("CALL sp_mamba_etl_setup")) {
                    statement.setString(1, props.getOpenmrsDatabase());
                    statement.setString(2, props.getEtlDatababase());
                    statement.setString(3, props.getLocale());
                    statement.setInt(4, props.getColumns());
                    statement.setInt(5, props.getIncremental());
                    statement.setInt(6, props.getAutomated());
                    statement.setInt(7, props.getInterval());
                } else if (props != null && sql.contains("CREATE EVENT IF NOT EXISTS _mamba_etl_scheduler_event")) {
                    statement.setInt(1, props.getInterval());
                }
                statement.execute();
            }
        }
    }
}