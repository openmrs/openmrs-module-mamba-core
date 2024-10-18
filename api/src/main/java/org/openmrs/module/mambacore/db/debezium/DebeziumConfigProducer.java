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

import io.debezium.config.Configuration;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class DebeziumConfigProducer {

    private static final String DEBEZIUM_DIR = "debezium";
    private static final String OFFSETS_FILE_SUFFIX = "_offsets.dat";
    private static final String SCHEMA_HISTORY_FILE_SUFFIX = "_schema_history.dat";

    private final DebeziumProperties properties;
    private final String appDataDir;

    public DebeziumConfigProducer(DebeziumProperties properties, Properties mainProperties) {
        this.properties = properties;
        this.appDataDir = mainProperties.getAppDataDir();
    }

    public Configuration createDebeziumConfig() {

        File debeziumConfigDir = new File(appDataDir, DEBEZIUM_DIR);
        ensureDirectoryExists(debeziumConfigDir);

        String serverId = properties.getDbServerId();
        File offsetsDataFile = new File(debeziumConfigDir, serverId + OFFSETS_FILE_SUFFIX);
        File schemaHistoryDataFile = new File(debeziumConfigDir, serverId + SCHEMA_HISTORY_FILE_SUFFIX);

        Configuration.Builder configBuilder = Configuration.create();

        // database-related properties
        configBuilder
                .with(DebeziumConstants.NAME, properties.getConnectorName())
                .with(DebeziumConstants.DB_HOST, properties.getDbHostname())
                .with(DebeziumConstants.DB_PORT, properties.getDbPort())
                .with(DebeziumConstants.DB_NAME, properties.getDbName())
                .with(DebeziumConstants.DB_USERNAME, properties.getDbUser())
                .with(DebeziumConstants.DB_PASSWORD, properties.getDbPassword())
                .with(DebeziumConstants.DB_SERVER_ID, properties.getDbServerId())
                .with(DebeziumConstants.DB_SERVER_NAME, properties.getDbServerName())
                .with(DebeziumConstants.DB_INCLUDE_LIST, properties.getDbIncludeList())
                .with(DebeziumConstants.DB_EXCLUDE_LIST, properties.getDbExcludeList())
                .with(DebeziumConstants.DATABASE_TIMEZONE, properties.getDatabaseTimeZone())
                .with(DebeziumConstants.TABLE_INCLUDE_LIST, prepareTableList(properties.getTableIncludeList()))
                .with(DebeziumConstants.TABLE_EXCLUDE_LIST, prepareTableList(properties.getTableExcludeList()));

        // offset storage-related properties
        configBuilder
                .with(DebeziumConstants.OFFSET_STORAGE_FILE_NAME, offsetsDataFile.getAbsolutePath())
                .with(DebeziumConstants.OFFSET_STORAGE_DIR, properties.getOffsetStorageDir())
                .with(DebeziumConstants.OFFSET_STORAGE_IMPL, properties.getOffsetStorageImpl())
                .with(DebeziumConstants.OFFSET_FLUSH_INTERVAL_MS, properties.getOffsetFlushIntervalMs())
                .with(DebeziumConstants.OFFSET_FLUSH_TIMEOUT_MS, properties.getOffsetFlushTimeoutMs())
                .with(DebeziumConstants.OFFSET_FLUSH_SIZE, properties.getOffsetFlushSize());

        // snapshot-related properties
        configBuilder
                .with(DebeziumConstants.SNAPSHOT_MODE, properties.getSnapshotMode())
                .with(DebeziumConstants.SNAPSHOT_LOCKING_MODE, properties.getSnapshotLockingMode())
                .with(DebeziumConstants.SNAPSHOT_FETCH_SIZE, properties.getSnapshotFetchSize())
                .with(DebeziumConstants.SNAPSHOT_INCLUDE_COLLECTION_LIST, properties.getSnapshotIncludeCollectionList())
                .with(DebeziumConstants.SNAPSHOT_EXCLUDE_COLLECTION_LIST, properties.getSnapshotExcludeCollectionList())
                .with(DebeziumConstants.SNAPSHOT_DELAY_MS, properties.getSnapshotDelayMs());

        // connector-related properties
        configBuilder
                .with(DebeziumConstants.CONNECTOR_CLASS, properties.getConnectorClass())
                .with(DebeziumConstants.DATABASE_HISTORY_IMPL, properties.getDatabaseHistoryImpl())
                .with(DebeziumConstants.DATABASE_HISTORY_FILE_NAME, schemaHistoryDataFile.getAbsolutePath());

        // heartbeat properties
        configBuilder
                .with(DebeziumConstants.HEARTBEAT_INTERVAL_MS, properties.getHeartbeatIntervalMs())
                .with(DebeziumConstants.HEARTBEAT_TOPICS_PREFIX, properties.getHeartbeatTopicsPrefix());

        // event-related properties
        configBuilder
                .with(DebeziumConstants.MAX_BATCH_SIZE, properties.getMaxBatchSize())
                .with(DebeziumConstants.MAX_QUEUE_SIZE, properties.getMaxQueueSize())
                .with(DebeziumConstants.POLL_INTERVAL_MS, properties.getPollIntervalMs())
                .with(DebeziumConstants.SCHEMA_REFRESH_MODE, properties.getSchemaRefreshMode())
                .with(DebeziumConstants.TOMBSTONES_ON_DELETE, properties.isTombstonesOnDelete())
                .with(DebeziumConstants.PROVIDE_TRANSACTION_METADATA, properties.isProvideTransactionMetadata());

        // error handling-related properties
        configBuilder
                .with(DebeziumConstants.MAX_RETRIES, properties.getMaxRetries())
                .with(DebeziumConstants.RETRY_DELAY_MS, properties.getRetryDelayMs())
                .with(DebeziumConstants.MAX_RETRY_DURATION_MS, properties.getMaxRetryDurationMs());

        // additional general configurations
        configBuilder
                .with(DebeziumConstants.INCLUDE_SCHEMA_CHANGES, properties.isIncludeSchemaChanges())
                .with(DebeziumConstants.INCLUDE_QUERY, properties.isIncludeQuery())
                .with(DebeziumConstants.DECIMAL_HANDLING_MODE, properties.getDecimalHandlingMode())
                .with(DebeziumConstants.BINARY_HANDLING_MODE, properties.getBinaryHandlingMode());

        return configBuilder.build();
    }

    /**
     * Prefix tables to include with dbname if not prefixed
     */
    private String prepareTableList(List<String> tables) {
        return Optional.ofNullable(tables)
                .filter(t -> !t.isEmpty())
                .map(t -> {
                    String tablePrefix = StringUtils.isNotBlank(properties.getDbName()) ? properties.getDbName() + "." : "";
                    return t.stream()
                            .map(table -> table.startsWith(tablePrefix) ? table : tablePrefix + table)
                            .collect(Collectors.joining(","));
                })
                .orElse("");
    }

    private void ensureDirectoryExists(File directory) {
        if (!directory.exists() && !directory.mkdirs()) {
            throw new IllegalStateException("Unable to create directory: " + directory.getAbsolutePath());
        }
    }
}