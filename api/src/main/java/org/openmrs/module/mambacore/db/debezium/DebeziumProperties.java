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