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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

public class JdbcFlattenDatabaseDao implements FlattenDatabaseDao {

    private static final Logger log = LoggerFactory.getLogger(JdbcFlattenDatabaseDao.class);

    private static final String ETL_DEPLOY_SQL = "mamba/jdbc_create_stored_procedures.sql";
    private static final String MYSQL_COMMENT_REGEX = "--.*(?=\\n)";
    private static final String DELIMITER = "~-~-";

    @Override
    public void deployMambaEtl() {

        MambaETLProperties props = MambaETLProperties.getInstance();
        log.info("Deploying MambaETL, scheduled @interval: " + props.getInterval() + " seconds...");
        executeSqlScript(props);
        log.info("Done deploying MambaETL...");
    }

    private void executeSqlScript(MambaETLProperties props) {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

        try (InputStream stream = classLoader.getResourceAsStream(ETL_DEPLOY_SQL)) {

            if (stream == null) {
                log.error("SQL script not found: {}", ETL_DEPLOY_SQL);
                return;
            }

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
                    executeStatements(connection, sqlScript, props);
                } catch (SQLException e) {
                    log.error("SQLException while executing script", e);
                }
            } catch (IOException e) {
                log.error("Error reading temporary file", e);
            } finally {
                Files.deleteIfExists(modifiedEtlSqlFile);
            }
        } catch (IOException e) {
            log.error("IOException while reading script", e);
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