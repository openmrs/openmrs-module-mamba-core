package org.openmrs.module.mambacore.api.dao.impl;

import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.dao.FlattenDatabaseDao;
import org.openmrs.module.mambacore.db.ConnectionPoolManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Properties;
import java.util.stream.Collectors;

public class JdbcFlattenDatabaseDao implements FlattenDatabaseDao {

    private static final Logger log = LoggerFactory.getLogger(JdbcFlattenDatabaseDao.class);
    private static final String ETL_SCHEDULER_SQL = "/_core/database/mysql/mamba_main.sql";//TODO: needs to be adapted to be db agnostic
    private static final String MYSQL_COMMENT_REGEX = "--.*(?=\\n)";

    @Override
    public void executeFlatteningScript() {
        log.info("Starting executeFlatteningScript()");
        System.out.println("Starting executeFlatteningScript()");

        Properties properties = Context.getRuntimeProperties();
        String locale = getProperty(properties, "mambaetl.analysis.locale", "en");
        int columns = getIntProperty(properties, "mambaetl.analysis.columns", 50);
        int incremental = getIntProperty(properties, "mambaetl.analysis.incremental-mode", 0);
        int automated = getIntProperty(properties, "mambaetl.analysis.automated-flattening", 0);
        int interval = getIntProperty(properties, "mambaetl.analysis.etl-interval", 300);

        try (InputStream stream = JdbcFlattenDatabaseDao.class.getResourceAsStream(ETL_SCHEDULER_SQL)) {
            if (stream == null) {
                log.error("SQL script not found: {}", ETL_SCHEDULER_SQL);
                return;
            }

            String schedulerSql = new BufferedReader(new InputStreamReader(stream))
                    .lines()
                    .collect(Collectors.joining("\n"))
                    .replaceAll(MYSQL_COMMENT_REGEX, "");

            DataSource dataSource = ConnectionPoolManager.getInstance().getDataSource();

            try (Connection connection = dataSource.getConnection()) {
                executeSqlStatements(connection, schedulerSql, locale, columns, incremental, automated, interval);
            } catch (SQLException e) {
                log.error("SQLException while executing script", e);
            }
        } catch (IOException e) {
            log.error("IOException while reading script", e);
        }

        log.info("Finished executeFlatteningScript()");
        System.out.println("Finished executeFlatteningScript()");
    }

    private void executeSqlStatements(Connection connection, String schedulerSql, String locale, int columns, int incremental, int automated, int interval) throws SQLException {
        String[] sqlStatements = schedulerSql.split(";");

        for (String sql : sqlStatements) {
            if (sql.trim().isEmpty()) {
                continue;
            }

            try (PreparedStatement statement = connection.prepareStatement(connection.nativeSQL(sql.trim()))) {
                if (sql.contains("CALL sp_mamba_etl_setup")) {
                    statement.setString(1, locale);
                    statement.setInt(2, columns);
                    statement.setInt(3, incremental);
                    statement.setInt(4, automated);
                    statement.setInt(5, interval);
                } else if (sql.contains("CREATE EVENT")) {
                    statement.setInt(1, interval);
                }
                statement.execute();
            }
        }
    }

    private String getProperty(Properties properties, String key, String defaultValue) {
        String value = properties.getProperty(key);
        return (value == null || value.isEmpty()) ? defaultValue : value.trim();
    }

    private int getIntProperty(Properties properties, String key, int defaultValue) {
        String value = properties.getProperty(key);
        return (value == null || value.isEmpty()) ? defaultValue : Integer.parseInt(value.trim());
    }
}