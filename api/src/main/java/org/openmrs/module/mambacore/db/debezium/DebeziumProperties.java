package com.ayinza.util.debezium.domain.model;

import java.util.List;

/**
 * @author smallGod
 * @date: 17/10/2024
 */
public interface DebeziumProperties {

    String getConnectorName();

    // Offset storage-related properties
    String getOffsetStorageFileName();

    String getOffsetStorageDir();

    String getOffsetStorageImpl();

    int getOffsetFlushIntervalMs();

    int getOffsetFlushTimeoutMs();

    int getOffsetFlushSize();

    // Snapshot-related properties
    String getSnapshotMode();

    String getSnapshotLockingMode();

    int getSnapshotFetchSize();

    String getSnapshotIncludeCollectionList();

    String getSnapshotExcludeCollectionList();

    long getSnapshotDelayMs();

    // Connector-related properties
    String getConnectorClass();

    String getDatabaseHistoryImpl();

    String getDatabaseHistoryFileName();

    // Heartbeat properties
    long getHeartbeatIntervalMs();

    String getHeartbeatTopicsPrefix();

    // Event-related properties
    int getMaxBatchSize();

    int getMaxQueueSize();

    long getPollIntervalMs();

    String getSchemaRefreshMode();

    boolean isTombstonesOnDelete();

    boolean isProvideTransactionMetadata();

    // Database-related properties
    String getDbHostname();

    int getDbPort();

    String getDbName();

    String getDbUser();

    String getDbPassword();

    String getDbServerId();

    String getDbServerName();

    String getDbIncludeList();

    String getDbExcludeList();

    List<String> getTableIncludeList();

    List<String> getTableExcludeList();

    // Timezone-related properties
    String getDatabaseTimeZone();

    // Error handling-related properties
    int getMaxRetries();

    long getRetryDelayMs();

    long getMaxRetryDurationMs();

    // Additional general configurations
    boolean isIncludeSchemaChanges();

    boolean isIncludeQuery();

    String getDecimalHandlingMode();

    String getBinaryHandlingMode();
}