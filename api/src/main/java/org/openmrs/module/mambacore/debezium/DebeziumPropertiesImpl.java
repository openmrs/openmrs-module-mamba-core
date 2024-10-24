/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.debezium;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

/**
 * Implementation of DebeziumProperties to fetch configuration
 */

public class DebeziumPropertiesImpl implements DebeziumProperties {

    private String connectorName;

    private String dbHostname;

    private int dbPort;

    private String dbName;

    private String dbUser;

    private String dbPassword;

    private String dbServerId;

    private String dbServerName;

    private Optional<List<String>> dbIncludeList;

    private Optional<List<String>> dbExcludeList;

    private Optional<List<String>> tableIncludeList;

    private Optional<List<String>> tableExcludeList;

    private String databaseTimeZone;

    private String offsetStorageDir;

    private String offsetStorage;

    private int offsetFlushIntervalMs;

    private int offsetFlushTimeoutMs;

    private int offsetFlushSize;

    private String snapshotMode;

    private String snapshotLockingMode;

    private int snapshotFetchSize;

    private Optional<List<String>> snapshotIncludeCollectionList;

    private Optional<List<String>> snapshotExcludeCollectionList;

    private long snapshotDelayMs;

    private String connectorClass;

    private String databaseHistoryImpl;

    private String databaseHistoryFileName;

    private String schemaHistoryInternal;

    private long heartbeatIntervalMs;

    private String heartbeatTopicsPrefix;

    private int maxBatchSize;

    private int maxQueueSize;

    private long pollIntervalMs;

    private String schemaRefreshMode;

    private boolean tombstonesOnDelete;

    private boolean provideTransactionMetadata;

    private int maxRetries;

    private long retryDelayMs;

    private long maxRetryDurationMs;

    private boolean includeSchemaChanges;

    private boolean includeQuery;

    private String decimalHandlingMode;


    private String binaryHandlingMode;

    private String topicPrefix;

    @Override
    public String getConnectorName() {
        return connectorName;
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
    public String getDatabaseTimeZone() {
        return databaseTimeZone;
    }

    @Override
    public List<String> getDbIncludeList() {
        return dbIncludeList.orElse(Collections.emptyList());
    }

    @Override
    public List<String> getDbExcludeList() {
        return dbExcludeList.orElse(Collections.emptyList());
    }

    @Override
    public List<String> getTableIncludeList() {
        return tableIncludeList.orElse(Collections.emptyList());
    }

    @Override
    public List<String> getTableExcludeList() {
        return tableExcludeList.orElse(Collections.emptyList());
    }

    @Override
    public String getOffsetStorageDir() {
        return offsetStorageDir;
    }

    @Override
    public String getOffsetStorage() {
        return offsetStorage;
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
    public List<String> getSnapshotIncludeCollectionList() {
        return snapshotIncludeCollectionList.orElse(Collections.emptyList());
    }

    @Override
    public List<String> getSnapshotExcludeCollectionList() {
        return snapshotExcludeCollectionList.orElse(Collections.emptyList());
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
    public String getSchemaHistoryInternal() {
        return schemaHistoryInternal;
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

    @Override
    public String getTopicPrefix() {
        return topicPrefix;
    }
}