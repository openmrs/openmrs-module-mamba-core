package org.openmrs.module.mambacore.debezium;

import org.openmrs.module.mambacore.util.MambaETLProperties;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
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
    private final String appDataDir;
    private final List<String> dbIncludeList;
    private final List<String> dbExcludeList;
    private final List<String> tableIncludeList;
    private final List<String> tableExcludeList;

    private DebeziumProperties() {

        MambaETLProperties mambaProps = MambaETLProperties.getInstance();

        this.connectorClass = "io.debezium.connector.mysql.MySqlConnector";
        this.topicPrefix = "debezium";
        this.schemaHistoryInternal = "io.debezium.storage.file.history.FileSchemaHistory";

        this.connectorName = "mamba_debezium_connector";
        this.dbHostname = "localhost";
        this.dbPort = 3306;
        this.dbName = mambaProps.getOpenmrsDatabase();
        this.dbUser = mambaProps.getMambaETLuser();
        this.dbPassword = mambaProps.getMambaETLuserPassword();
        this.dbServerId = "85744";
        this.dbServerName = "debezium-app-connector";
        this.databaseTimeZone = "UTC";

        this.dbIncludeList = Collections.singletonList(mambaProps.getOpenmrsDatabase());
        this.dbExcludeList = Collections.emptyList();
        this.tableIncludeList = Arrays.asList("obs", "encounter");
        this.tableExcludeList = Collections.emptyList();

        this.offsetStorage = "org.openmrs.module.mambacore.debezium.RocksDBOffsetBackingStore";
        this.offsetStorageDir = "/tmp/rocksdb";

        this.maxBatchSize = 1024;
        this.maxQueueSize = 2000;
        this.pollIntervalMs = 5000;
        this.schemaRefreshMode = "initial";

        this.appDataDir = "/tmp";
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
        return dbIncludeList != null ? dbIncludeList : Collections.emptyList();
    }

    public List<String> getDbExcludeList() {
        return dbExcludeList != null ? dbExcludeList : Collections.emptyList();
    }

    public List<String> getTableIncludeList() {
        return tableIncludeList != null ? tableIncludeList : Collections.emptyList();
    }

    public List<String> getTableExcludeList() {
        return tableExcludeList != null ? tableExcludeList : Collections.emptyList();
    }

    public String getAppDataDir() {
        return appDataDir;
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
