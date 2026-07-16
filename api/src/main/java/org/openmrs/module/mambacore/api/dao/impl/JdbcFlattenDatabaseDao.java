package org.openmrs.module.mambacore.api.dao.impl;

import org.openmrs.module.mambacore.api.dao.FlattenDatabaseDao;
import org.openmrs.module.mambacore.db.ConnectionPoolManager;
import org.openmrs.module.mambacore.util.MambaETLProperties;
import org.openmrs.module.mambacore.util.StringReplacerUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class JdbcFlattenDatabaseDao implements FlattenDatabaseDao {

    private static final Logger log = LoggerFactory.getLogger(JdbcFlattenDatabaseDao.class);

    private static final String ETL_DEPLOY_SQL = "mamba/jdbc_create_stored_procedures.sql";
    private static final String MYSQL_COMMENT_REGEX = "--[^\\n]*";
    private static final String DELIMITER = "~-~-";

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
            executeSqlScript(stream, props);
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

        // Deploy each SQL file
        int successCount = 0;
        int failureCount = 0;
        for (Path sqlFile : sqlFiles) {
            log.info("Deploying ETL script: {}", sqlFile.getFileName());
            try (InputStream stream = Files.newInputStream(sqlFile)) {
                executeSqlScript(stream, props);
                successCount++;
            } catch (IOException e) {
                failureCount++;
                log.error("Error processing SQL file: {}", sqlFile, e);
            } catch (RuntimeException e) {
                failureCount++;
                log.error("Error executing SQL script: {}", sqlFile, e);
            }
        }

        if (failureCount > 0) {
            log.warn("ETL deployment completed with {} successes and {} failures", successCount, failureCount);
        }
    }

    private List<Path> discoverSqlFiles(String directoryPath, MambaETLProperties props) throws IOException {
        List<Path> sqlFiles = new ArrayList<>();
        Path directory = Paths.get(directoryPath);

        if (!Files.exists(directory) || !Files.isDirectory(directory)) {
            log.warn("External ETL directory does not exist or is not a directory: {}", directoryPath);
            return sqlFiles;
        }

        // Find all .sql files in the directory (configurable maxDepth with default of 5)
        int maxDepth = props.getEtlDiscoveryDepth();
        try {
            Files.walk(directory, maxDepth)
                    .filter(Files::isRegularFile)
                    .filter(path -> {
                        String pathStr = path.toString();
                        return pathStr.toLowerCase().endsWith(".sql");
                    })
                    .forEach(sqlFiles::add);
        } catch (java.nio.file.FileSystemLoopException e) {
            log.warn("Symbolic link cycle detected in ETL directory, skipping affected paths: {}", directoryPath, e);
        }

        return sqlFiles;
    }

    private void executeSqlScript(InputStream stream, MambaETLProperties props) {
        try {
            Map<String, String> replacements = new HashMap<>();
            replacements.put("mamba_source_db", props.getOpenmrsDatabase());
            replacements.put("mamba_etl_db", props.getEtlDatababase());

            Path modifiedEtlSqlFile = StringReplacerUtil.replaceStrings(stream, replacements);

            try (BufferedReader reader = Files.newBufferedReader(modifiedEtlSqlFile, StandardCharsets.UTF_8)) {
                String sqlScript = reader.lines()
                        .collect(Collectors.joining("\n"))
                        .replaceAll(MYSQL_COMMENT_REGEX, "");

                DataSource dataSource = ConnectionPoolManager
                        .getInstance()
                        .getDefaultDataSource();

                try (Connection connection = dataSource.getConnection()) {
                    // Disable auto-commit to manage transaction explicitly
                    boolean originalAutoCommit;
                    try {
                        originalAutoCommit = connection.getAutoCommit();
                        connection.setAutoCommit(false);
                    } catch (SQLException e) {
                        log.error("Failed to configure transaction auto-commit", e);
                        throw new RuntimeException("Failed to configure transaction for SQL execution", e);
                    }

                    SQLException executionError = null;
                    try {
                        executeStatements(connection, sqlScript, props);
                        connection.commit();
                        log.info("SQL script executed successfully");
                    } catch (SQLException e) {
                        executionError = e;
                        log.error("SQLException while executing script, rolling back", e);
                        // Attempt rollback but don't let its failure hide the original error
                        try {
                            connection.rollback();
                        } catch (SQLException rollbackEx) {
                            log.warn("Rollback failed after SQL execution error: {}", rollbackEx.getMessage(), rollbackEx);
                        }
                        throw new RuntimeException("SQL execution failed, transaction rolled back", executionError);
                    } finally {
                        // Restore auto-commit, don't let exceptions here suppress the original
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
                log.error("Error reading temporary file", e);
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