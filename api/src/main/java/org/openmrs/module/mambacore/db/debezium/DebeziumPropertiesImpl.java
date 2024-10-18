/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.db.debezium;

import java.util.List;

public class DebeziumPropertiesImpl implements DebeziumProperties {

    private String connectorName;

    // Database connection properties
    private String dbHostname;

    private int dbPort;

    private String dbName;

    private String dbUser;

    private String dbPassword;

    private String dbServerId = "85744";// Server ID for MySQL replication

    private String dbServerName;

    private String dbIncludeList;

    private String dbExcludeList;

    private String databaseTimeZone = "UTC";

    private List<String> tableIncludeList;

    private List<String> tableExcludeList;

    // Offset storage-related properties
    private String offsetStorageFileName = "offsets.dat";

    private String offsetStorageDir = "/tmp";

    private String offsetStorageImpl = "org.apache.kafka.connect.storage.FileOffsetBackingStore";

    private int offsetFlushIntervalMs = 60000;// 60 seconds: interval at which Debezium will persist the current offset position

    private int offsetFlushTimeoutMs = 15000;

    private int offsetFlushSize = 1000;

    // Snapshot-related properties
    private String snapshotMode = "when_needed";

    private String snapshotLockingMode = "none";

    private int snapshotFetchSize = 10000;

    private String snapshotIncludeCollectionList;// Specify tables to include during snapshot

    private String snapshotExcludeCollectionList;

    private long snapshotDelayMs = 0;

    // Connector-related properties
    private String connectorClass = "io.debezium.connector.mysql.MySqlConnector";

    private String databaseHistoryImpl = "io.debezium.relational.history.FileDatabaseHistory";

    private String databaseHistoryFileName = "dbhistory.dat";

    // Heartbeat properties
    private long heartbeatIntervalMs = 0;// No heartbeat by default

    private String heartbeatTopicsPrefix = "__debezium-heartbeat";

    // Event-related properties
    private int maxBatchSize = 2048;

    private int maxQueueSize = 8192;

    private long pollIntervalMs = 500;

    private String schemaRefreshMode = "columns_diff";// How schema changes are handled, can also be 'columns_diff_exclude_unchanged_toast'

    private boolean tombstonesOnDelete = false;

    private boolean provideTransactionMetadata = false;

    // Error handling-related properties

    private int maxRetries = 10;// Max retry attempts for failed tasks

    private long retryDelayMs = 1000;

    private long maxRetryDurationMs = 60000;

    // Additional general configurations
    private boolean includeSchemaChanges = true;

    private boolean includeQuery = false;

    private String decimalHandlingMode = "precise";// How to handle decimal types: 'precise', 'string', 'double'

    private String binaryHandlingMode = "bytes";// How to handle binary fields: 'bytes', 'base64'

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