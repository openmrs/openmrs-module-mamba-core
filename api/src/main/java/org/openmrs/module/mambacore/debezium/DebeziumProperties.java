package org.openmrs.module.mambacore.debezium;

import org.openmrs.module.mambacore.util.MambaETLProperties;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.Properties;

public class DebeziumProperties {

    private static volatile DebeziumProperties instance;

    private final String connectorClass;

    private final String connectorName;

    private final String dbHostname;

    private final int dbPort;

    private final String dbName;

    private final String dbUser;

    private final String dbPassword;

    private final String dbServerId;

    private final String dbServerName;
    private final String databaseTimeZone;
    private final String offsetStorageDir;
    private final String offsetStorage;
    private final String schemaHistoryInternal;
    private final int maxBatchSize;
    private final int maxQueueSize;
    private final long pollIntervalMs;
    private final String schemaRefreshMode;
    private final String topicPrefix;
    private Optional<List<String>> dbIncludeList;
    private Optional<List<String>> dbExcludeList;
    private Optional<List<String>> tableIncludeList;
    private Optional<List<String>> tableExcludeList;

    private DebeziumProperties() {

        MambaETLProperties mambaProps = MambaETLProperties.getInstance();

        this.connectorClass = mambaProps.getProperty("connection.driver_class");
        this.topicPrefix = mambaProps.getProperty("connection.url");
        this.schemaHistoryInternal = mambaProps.getProperty("mambaetl.analysis.db.username", mambaProps.getProperty("connection.username"));

        this.connectorName = getIntProperty(mambaProps, "mambaetl.analysis.columns", 40);
        this.dbHostname = getProperty(mambaProps, "mambaetl.analysis.db.etl_database", "analysis_db");
        this.dbPort = getProperty(mambaProps, "mambaetl.analysis.locale", "en");
        this.dbName = mambaProps.getOpenmrsDatabase();
        this.dbUser = getIntProperty(mambaProps, "mambaetl.analysis.incremental_mode", 1);
        this.dbPassword = getIntProperty(mambaProps, "mambaetl.analysis.automated_flattening", 0);
        this.dbServerId = getIntProperty(mambaProps, "mambaetl.analysis.etl_interval", 300);
        this.dbServerName = Arrays.asList("obs", "encounter");
        this.databaseTimeZone = Arrays.asList("obs", "encounter");

        this.dbIncludeList = Arrays.asList("obs", "encounter");
        this.dbExcludeList = Arrays.asList("obs", "encounter");
        this.tableIncludeList = Arrays.asList("obs", "encounter");
        this.tableExcludeList = Arrays.asList("obs", "encounter");

        this.offsetStorage = Arrays.asList("obs", "encounter");
        this.offsetStorageDir = Arrays.asList("obs", "encounter");

        this.maxBatchSize = Arrays.asList("obs", "encounter");
        this.maxQueueSize = Arrays.asList("obs", "encounter");
        this.pollIntervalMs = Arrays.asList("obs", "encounter");
        this.schemaRefreshMode = Arrays.asList("obs", "encounter");
    }

    public static synchronized DebeziumProperties getInstance() {
        if (instance == null) {
            instance = new DebeziumProperties();
        }
        return instance;
    }

    public String getConnectorClass() {
        return connectorClass;
    }

    public String getConnectorName() {
        return connectorName;
    }

    public String getDbHostname() {
        return dbHostname;
    }

    public int getDbPort() {
        return dbPort;
    }

    public String getDbName() {
        return dbName;
    }

    public String getDbUser() {
        return dbUser;
    }

    public String getDbPassword() {
        return dbPassword;
    }

    public String getDbServerId() {
        return dbServerId;
    }

    public String getDbServerName() {
        return dbServerName;
    }

    public String getDatabaseTimeZone() {
        return databaseTimeZone;
    }

    public String getOffsetStorageDir() {
        return offsetStorageDir;
    }

    public String getOffsetStorage() {
        return offsetStorage;
    }

    public String getSchemaHistoryInternal() {
        return schemaHistoryInternal;
    }

    public int getMaxBatchSize() {
        return maxBatchSize;
    }

    public int getMaxQueueSize() {
        return maxQueueSize;
    }

    public long getPollIntervalMs() {
        return pollIntervalMs;
    }

    public String getSchemaRefreshMode() {
        return schemaRefreshMode;
    }

    public String getTopicPrefix() {
        return topicPrefix;
    }

    public List<String> getDbIncludeList() {
        return dbIncludeList.orElse(Collections.emptyList());
    }

    public List<String> getDbExcludeList() {
        return dbExcludeList.orElse(Collections.emptyList());
    }

    public List<String> getTableIncludeList() {
        return tableIncludeList.orElse(Collections.emptyList());
    }

    public List<String> getTableExcludeList() {
        return tableExcludeList.orElse(Collections.emptyList());
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
