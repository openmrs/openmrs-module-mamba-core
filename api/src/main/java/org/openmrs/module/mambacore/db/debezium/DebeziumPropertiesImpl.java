package com.ayinza.util.debezium.application.model;

import com.ayinza.utils.domain.model.debezium.DebeziumProperties;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.util.List;

/**
 * Implementation of DebeziumProperties to fetch configuration from MicroProfile Config.
 *
 * @author smallGod
 * @date: 15/09/2024
 */
@ApplicationScoped
public class DebeziumPropertiesImpl implements DebeziumProperties {

    @Inject
    @ConfigProperty(name = "name")
    private String connectorName;

    // Database connection properties
    @Inject
    @ConfigProperty(name = "database.hostname")
    private String dbHostname;

    @Inject
    @ConfigProperty(name = "database.port")
    private int dbPort;

    @Inject
    @ConfigProperty(name = "database.name")
    private String dbName;

    @Inject
    @ConfigProperty(name = "database.user")
    private String dbUser;

    @Inject
    @ConfigProperty(name = "database.password")
    private String dbPassword;

    @Inject
    @ConfigProperty(name = "database.server.id", defaultValue = "85744")
    private String dbServerId;// Server ID for MySQL replication

    @Inject
    @ConfigProperty(name = "database.server.name", defaultValue = "debezium-app-connector")
    private String dbServerName;

    @Inject
    @ConfigProperty(name = "database.include.list", defaultValue = "")
    private String dbIncludeList;

    @Inject
    @ConfigProperty(name = "database.exclude.list", defaultValue = "")
    private String dbExcludeList;

    @Inject
    @ConfigProperty(name = "database.timezone", defaultValue = "UTC")
    private String databaseTimeZone;

    @Inject
    @ConfigProperty(name = "table.include.list", defaultValue = "")
    private List<String> tableIncludeList;

    @Inject
    @ConfigProperty(name = "table.exclude.list", defaultValue = "")
    private List<String> tableExcludeList;

    // Offset storage-related properties
    @Inject
    @ConfigProperty(name = "offset.storage.file.name", defaultValue = "offsets.dat")
    private String offsetStorageFileName;

    @Inject
    @ConfigProperty(name = "offset.storage.dir", defaultValue = "/tmp")
    private String offsetStorageDir;

    @Inject
    @ConfigProperty(name = "offset.storage.impl", defaultValue = "org.apache.kafka.connect.storage.FileOffsetBackingStore")
    private String offsetStorageImpl;

    @Inject
    @ConfigProperty(name = "offset.flush.interval.ms", defaultValue = "60000")
    private int offsetFlushIntervalMs;// 60 seconds: interval at which Debezium will persist the current offset position

    @Inject
    @ConfigProperty(name = "offset.flush.timeout.ms", defaultValue = "15000")
    private int offsetFlushTimeoutMs;

    @Inject
    @ConfigProperty(name = "offset.flush.size", defaultValue = "1000")
    private int offsetFlushSize;

    // Snapshot-related properties
    @Inject
    @ConfigProperty(name = "snapshot.mode", defaultValue = "when_needed")
    private String snapshotMode;

    @Inject
    @ConfigProperty(name = "snapshot.locking.mode", defaultValue = "none")
    private String snapshotLockingMode;

    @Inject
    @ConfigProperty(name = "snapshot.fetch.size", defaultValue = "10000")
    private int snapshotFetchSize;

    @Inject
    @ConfigProperty(name = "snapshot.include.collection.list", defaultValue = "")
    private String snapshotIncludeCollectionList;// Specify tables to include during snapshot

    @Inject
    @ConfigProperty(name = "snapshot.exclude.collection.list", defaultValue = "")
    private String snapshotExcludeCollectionList;

    @Inject
    @ConfigProperty(name = "snapshot.delay.ms", defaultValue = "0")
    private long snapshotDelayMs;

    // Connector-related properties
    @Inject
    @ConfigProperty(name = "connector.class", defaultValue = "io.debezium.connector.mysql.MySqlConnector")
    private String connectorClass;

    @Inject
    @ConfigProperty(name = "database.history.impl", defaultValue = "io.debezium.relational.history.FileDatabaseHistory")
    private String databaseHistoryImpl;

    @Inject
    @ConfigProperty(name = "database.history.file.name", defaultValue = "dbhistory.dat")
    private String databaseHistoryFileName;

    // Heartbeat properties
    @Inject
    @ConfigProperty(name = "heartbeat.interval.ms", defaultValue = "0")
    private long heartbeatIntervalMs;// No heartbeat by default

    @Inject
    @ConfigProperty(name = "heartbeat.topics.prefix", defaultValue = "__debezium-heartbeat")
    private String heartbeatTopicsPrefix;

    // Event-related properties
    @Inject
    @ConfigProperty(name = "max.batch.size", defaultValue = "2048")
    private int maxBatchSize;

    @Inject
    @ConfigProperty(name = "max.queue.size", defaultValue = "8192")
    private int maxQueueSize;

    @Inject
    @ConfigProperty(name = "poll.interval.ms", defaultValue = "500")
    private long pollIntervalMs;

    @Inject
    @ConfigProperty(name = "schema.refresh.mode", defaultValue = "columns_diff")
    private String schemaRefreshMode;// How schema changes are handled, can also be 'columns_diff_exclude_unchanged_toast'

    @Inject
    @ConfigProperty(name = "tombstones.on.delete", defaultValue = "false")
    private boolean tombstonesOnDelete;

    @Inject
    @ConfigProperty(name = "provide.transaction.metadata", defaultValue = "false")
    private boolean provideTransactionMetadata;

    // Error handling-related properties
    @Inject
    @ConfigProperty(name = "max.retries", defaultValue = "10")
    private int maxRetries;// Max retry attempts for failed tasks

    @Inject
    @ConfigProperty(name = "retry.delay.ms", defaultValue = "1000")
    private long retryDelayMs;

    @Inject
    @ConfigProperty(name = "max.retry.duration.ms", defaultValue = "60000")
    private long maxRetryDurationMs;

    // Additional general configurations
    @Inject
    @ConfigProperty(name = "include.schema.changes", defaultValue = "true")
    private boolean includeSchemaChanges;

    @Inject
    @ConfigProperty(name = "include.query", defaultValue = "false")
    private boolean includeQuery;

    @Inject
    @ConfigProperty(name = "decimal.handling.mode", defaultValue = "precise")
    private String decimalHandlingMode;// How to handle decimal types: 'precise', 'string', 'double'

    @Inject
    @ConfigProperty(name = "binary.handling.mode", defaultValue = "bytes")
    private String binaryHandlingMode;// How to handle binary fields: 'bytes', 'base64'

    @Override
    public String getConnectorName() {
        return connectorName; // Return your desired connector name
    }

    @Override
    public String getDbHostname() {
        return dbHostname;
    }

    @Override
    public int getDbPort() {
        return dbPort;
    }

    @Override
    public String getDbName() {
        return dbName;
    }

    @Override
    public String getDbUser() {
        return dbUser;
    }

    @Override
    public String getDbPassword() {
        return dbPassword;
    }

    @Override
    public String getDbServerId() {
        return dbServerId;
    }

    @Override
    public String getDbServerName() {
        return dbServerName;
    }

    @Override
    public String getDbIncludeList() {
        return dbIncludeList;
    }

    @Override
    public String getDbExcludeList() {
        return dbExcludeList;
    }

    @Override
    public String getDatabaseTimeZone() {
        return databaseTimeZone;
    }

    @Override
    public List<String> getTableIncludeList() {
        return tableIncludeList;
    }

    @Override
    public List<String> getTableExcludeList() {
        return tableExcludeList;
    }

    @Override
    public String getOffsetStorageFileName() {
        return offsetStorageFileName;
    }

    @Override
    public String getOffsetStorageDir() {
        return offsetStorageDir;
    }

    @Override
    public String getOffsetStorageImpl() {
        return offsetStorageImpl;
    }

    @Override
    public int getOffsetFlushIntervalMs() {
        return offsetFlushIntervalMs;
    }

    @Override
    public int getOffsetFlushTimeoutMs() {
        return offsetFlushTimeoutMs;
    }

    @Override
    public int getOffsetFlushSize() {
        return offsetFlushSize;
    }

    @Override
    public String getSnapshotMode() {
        return snapshotMode;
    }

    @Override
    public String getSnapshotLockingMode() {
        return snapshotLockingMode;
    }

    @Override
    public int getSnapshotFetchSize() {
        return snapshotFetchSize;
    }

    @Override
    public String getSnapshotIncludeCollectionList() {
        return snapshotIncludeCollectionList;
    }

    @Override
    public String getSnapshotExcludeCollectionList() {
        return snapshotExcludeCollectionList;
    }

    @Override
    public long getSnapshotDelayMs() {
        return snapshotDelayMs;
    }

    @Override
    public String getConnectorClass() {
        return connectorClass;
    }

    @Override
    public String getDatabaseHistoryImpl() {
        return databaseHistoryImpl;
    }

    @Override
    public String getDatabaseHistoryFileName() {
        return databaseHistoryFileName;
    }

    @Override
    public long getHeartbeatIntervalMs() {
        return heartbeatIntervalMs;
    }

    @Override
    public String getHeartbeatTopicsPrefix() {
        return heartbeatTopicsPrefix;
    }

    @Override
    public int getMaxBatchSize() {
        return maxBatchSize;
    }

    @Override
    public int getMaxQueueSize() {
        return maxQueueSize;
    }

    @Override
    public long getPollIntervalMs() {
        return pollIntervalMs;
    }

    @Override
    public String getSchemaRefreshMode() {
        return schemaRefreshMode;
    }

    @Override
    public String getDecimalHandlingMode() {
        return decimalHandlingMode;
    }

    @Override
    public String getBinaryHandlingMode() {
        return binaryHandlingMode;
    }

    @Override
    public boolean isTombstonesOnDelete() {
        return tombstonesOnDelete;
    }

    @Override
    public boolean isProvideTransactionMetadata() {
        return provideTransactionMetadata;
    }

    @Override
    public int getMaxRetries() {
        return maxRetries;
    }

    @Override
    public long getRetryDelayMs() {
        return retryDelayMs;
    }

    @Override
    public long getMaxRetryDurationMs() {
        return maxRetryDurationMs;
    }

    @Override
    public boolean isIncludeSchemaChanges() {
        return includeSchemaChanges;
    }

    @Override
    public boolean isIncludeQuery() {
        return includeQuery;
    }
}