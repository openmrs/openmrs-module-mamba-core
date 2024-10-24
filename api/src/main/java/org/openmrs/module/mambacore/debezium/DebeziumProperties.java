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

import java.util.List;

public interface DebeziumProperties {

    String getConnectorName();

    String getOffsetStorageDir();

    String getOffsetStorage();

    int getOffsetFlushIntervalMs();

    int getOffsetFlushTimeoutMs();

    int getOffsetFlushSize();

    String getSnapshotMode();

    String getSnapshotLockingMode();

    int getSnapshotFetchSize();

    List<String> getSnapshotIncludeCollectionList();

    List<String> getSnapshotExcludeCollectionList();

    long getSnapshotDelayMs();

    String getConnectorClass();

    String getDatabaseHistoryImpl();

    String getDatabaseHistoryFileName();

    String getSchemaHistoryInternal();

    // Heartbeat properties
    long getHeartbeatIntervalMs();

    String getHeartbeatTopicsPrefix();

    int getMaxBatchSize();

    int getMaxQueueSize();

    long getPollIntervalMs();

    String getSchemaRefreshMode();

    boolean isTombstonesOnDelete();

    boolean isProvideTransactionMetadata();

    String getDbHostname();

    int getDbPort();

    String getDbName();

    String getDbUser();

    String getDbPassword();

    String getDbServerId();

    String getDbServerName();

    List<String> getDbIncludeList();

    List<String> getDbExcludeList();

    List<String> getTableIncludeList();

    List<String> getTableExcludeList();

    String getDatabaseTimeZone();

    int getMaxRetries();

    long getRetryDelayMs();

    long getMaxRetryDurationMs();

    boolean isIncludeSchemaChanges();

    boolean isIncludeQuery();

    String getDecimalHandlingMode();

    String getBinaryHandlingMode();

    String getTopicPrefix();
}