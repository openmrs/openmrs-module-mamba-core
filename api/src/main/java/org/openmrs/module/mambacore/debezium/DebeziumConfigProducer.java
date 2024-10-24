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

import io.debezium.config.Configuration;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class DebeziumConfigProducer {

    private static final String DEBEZIUM_DIR = "debezium";
    private static final String SCHEMA_HISTORY_FILE_SUFFIX = "_schema_history.dat";

    private final DebeziumProperties properties;
    private final String appDataDir;

    public DebeziumConfigProducer(DebeziumProperties properties, Properties mainProperties) {
        this.properties = properties;
        this.appDataDir = mainProperties.getAppDataDir();
    }

    @Produces
    public Configuration createDebeziumConfig() {

        File debeziumConfigDir = new File(appDataDir, DEBEZIUM_DIR);
        ensureDirectoryExists(debeziumConfigDir);

        String serverId = properties.getDbServerId();
        File schemaHistoryDataFile = new File(debeziumConfigDir, serverId + SCHEMA_HISTORY_FILE_SUFFIX);

        Configuration.Builder configBuilder = Configuration.create();

        // essential configs
        configBuilder
                .with(DebeziumConstants.CONNECTOR_CLASS, properties.getConnectorClass())
                .with(DebeziumConstants.TOPIC_PREFIX, properties.getTopicPrefix())
                .with(DebeziumConstants.SCHEMA_HISTORY_INTERNAL, properties.getSchemaHistoryInternal())
                .with(DebeziumConstants.SCHEMA_HISTORY_INTERNAL_FILE, schemaHistoryDataFile.getAbsolutePath());

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
                .with(DebeziumConstants.DATABASE_TIMEZONE, properties.getDatabaseTimeZone());

        Optional.ofNullable(properties.getDbIncludeList())
                .filter(list -> !list.isEmpty())
                .ifPresent(list -> configBuilder.with(DebeziumConstants.DB_INCLUDE_LIST, prepareDatabaseList(list)));

        Optional.ofNullable(properties.getDbExcludeList())
                .filter(list -> !list.isEmpty())
                .ifPresent(list -> configBuilder.with(DebeziumConstants.DB_EXCLUDE_LIST, prepareDatabaseList(list)));

        Optional.ofNullable(properties.getTableIncludeList())
                .filter(list -> !list.isEmpty())
                .ifPresent(list -> configBuilder.with(DebeziumConstants.TABLE_INCLUDE_LIST, prepareTableList(list)));

        Optional.ofNullable(properties.getTableExcludeList())
                .filter(list -> !list.isEmpty())
                .ifPresent(list -> configBuilder.with(DebeziumConstants.TABLE_EXCLUDE_LIST, prepareTableList(list)));

        // offset storage-related properties
        configBuilder
                .with(DebeziumConstants.OFFSET_STORAGE, properties.getOffsetStorage())
                .with(DebeziumConstants.OFFSET_STORAGE_DIR, properties.getOffsetStorageDir());

        // event-related properties
        configBuilder
                .with(DebeziumConstants.MAX_BATCH_SIZE, properties.getMaxBatchSize())
                .with(DebeziumConstants.MAX_QUEUE_SIZE, properties.getMaxQueueSize())
                .with(DebeziumConstants.POLL_INTERVAL_MS, properties.getPollIntervalMs())
                .with(DebeziumConstants.SCHEMA_REFRESH_MODE, properties.getSchemaRefreshMode());

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

    private String prepareDatabaseList(List<String> databases) {
        return Optional.ofNullable(databases)
                .filter(t -> !t.isEmpty())
                .map(t -> {
                    return String.join(",", t);
                })
                .orElse("");
    }

    private void ensureDirectoryExists(File directory) {
        if (!directory.exists() && !directory.mkdirs()) {
            throw new IllegalStateException("Unable to create directory: " + directory.getAbsolutePath());
        }
    }
}