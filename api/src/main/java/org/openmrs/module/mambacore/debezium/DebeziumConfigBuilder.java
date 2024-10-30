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
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class DebeziumConfigBuilder {

    private static final String DEBEZIUM_DIR = "debezium";
    private static final String SCHEMA_HISTORY_FILE_SUFFIX = "_schema_history.dat";
    private static volatile DebeziumConfigBuilder instance = null;
    private static Configuration config;
    private final DebeziumProperties props = DebeziumProperties.getInstance();

    private DebeziumConfigBuilder() {
        try {
            config = createDebeziumConfig();
        } catch (Exception e) {
            System.err.println("Error initializing Debezium configuration: " + e.getMessage());
        }
    }

    public static DebeziumConfigBuilder getInstance() {
        if (instance == null) {
            synchronized (DebeziumConfigBuilder.class) {
                if (instance == null) {
                    instance = new DebeziumConfigBuilder();
                }
            }
        }
        return instance;
    }

    public Configuration build() {
        return config;
    }

    private Configuration createDebeziumConfig() throws IOException {

        final String MYSQL_CONNECTOR_CLASS = "io.debezium.connector.mysql.MySqlConnector";
        final String FILE_DB_HISTORY = "io.debezium.relational.history.FileDatabaseHistory";
        final String CONNECTOR_NAME = "mamba-core-connector";
        final String SERVER_NAME = "openmrsDbServer";

        File debeziumConfigDir = new File(props.getAppDataDir(), DEBEZIUM_DIR);
        ensureDirectoryExists(debeziumConfigDir);

        String serverId = props.getDbServerId();
        File schemaHistoryDataFile = new File(debeziumConfigDir, serverId + SCHEMA_HISTORY_FILE_SUFFIX);

        String source = props.getDbName();
        File dbHistoryTempFile = File.createTempFile("dbhistory_", ".dat");
        File offsetsDataFile = new File(debeziumConfigDir, serverId + "_offsets.dat");

        return Configuration.create()
                .with("name", props.getConnectorName())
                .with("connector.class", props.getConnectorClass())
                .with("offset.storage", "org.apache.kafka.connect.storage.FileOffsetBackingStore")
                .with("offset.storage.file.filename", offsetsDataFile.getAbsolutePath())
                .with("offset.flush.interval.ms", "0")
                .with("offset.flush.timeout.ms", "5000")
                .with("include.schema.changes", "true")
                .with("database.server.id", props.getDbServerId())
                .with("database.server.name", source)
                .with("database.history", FILE_DB_HISTORY)
                .with("database.history.file.filename", schemaHistoryDataFile.getAbsolutePath())
                .with("decimal.handling.mode", "double")
                .with("tombstones.on.delete", "false")
                .with("snapshot.mode", "when_needed")
                .with("database.user", props.getDbUser())
                .with("database.password", props.getDbPassword())
                .with("database.hostname", props.getDbHostname())
                .with("database.port", props.getDbPort())
                .with("database.dbname", source)
                .with("database.include.list", source)
                .with("table.include.list", "openmrs.person, openmrs.patient, openmrs.obs")
                .with("database.history.skip.unparseable.ddl", "true")
                .with("key.column", "openmrs.obs:obs_id,openmrs.encounter:encounter_id") //TODO: change this
                .build();
    }

    private Configuration createDebeziumConfig2() {

        File debeziumConfigDir = new File(props.getAppDataDir(), DEBEZIUM_DIR);
        ensureDirectoryExists(debeziumConfigDir);

        String serverId = props.getDbServerId();
        File schemaHistoryDataFile = new File(debeziumConfigDir, serverId + SCHEMA_HISTORY_FILE_SUFFIX);

        Configuration.Builder configBuilder = Configuration.create();

        // essential configs
        configBuilder
                .with(DebeziumConstants.CONNECTOR_CLASS, props.getConnectorClass())
                .with(DebeziumConstants.TOPIC_PREFIX, props.getTopicPrefix())
                .with(DebeziumConstants.SCHEMA_HISTORY_INTERNAL, props.getSchemaHistoryInternal())
                .with(DebeziumConstants.SCHEMA_HISTORY_INTERNAL_FILE, schemaHistoryDataFile.getAbsolutePath());

        // database-related props
        configBuilder
                .with(DebeziumConstants.NAME, props.getConnectorName())
                .with(DebeziumConstants.DB_HOST, props.getDbHostname())
                .with(DebeziumConstants.DB_PORT, props.getDbPort())
                .with(DebeziumConstants.DB_NAME, props.getDbName())
                .with(DebeziumConstants.DB_USERNAME, props.getDbUser())
                .with(DebeziumConstants.DB_PASSWORD, props.getDbPassword())
                .with(DebeziumConstants.DB_SERVER_ID, props.getDbServerId())
                .with(DebeziumConstants.DB_SERVER_NAME, props.getDbServerName())
                .with(DebeziumConstants.DATABASE_TIMEZONE, props.getDatabaseTimeZone());

        List<String> dbIncludeList = props.getDbIncludeList();
        if (dbIncludeList != null && !dbIncludeList.isEmpty()) {
            configBuilder.with(DebeziumConstants.DB_INCLUDE_LIST, prepareDatabaseList(dbIncludeList));
        }

        List<String> dbExcludeList = props.getDbExcludeList();
        if (dbExcludeList != null && !dbExcludeList.isEmpty()) {
            configBuilder.with(DebeziumConstants.DB_EXCLUDE_LIST, prepareDatabaseList(dbExcludeList));
        }

        List<String> tableIncludeList = props.getTableIncludeList();
        if (tableIncludeList != null && !tableIncludeList.isEmpty()) {
            configBuilder.with(DebeziumConstants.TABLE_INCLUDE_LIST, prepareTableList(tableIncludeList));
        }

        List<String> tableExcludeList = props.getTableExcludeList();
        if (tableExcludeList != null && !tableExcludeList.isEmpty()) {
            configBuilder.with(DebeziumConstants.TABLE_EXCLUDE_LIST, prepareTableList(tableExcludeList));
        }

        // offset storage-related props
        configBuilder
                .with(DebeziumConstants.OFFSET_STORAGE, props.getOffsetStorage())
                .with(DebeziumConstants.OFFSET_STORAGE_DIR, props.getOffsetStorageDir());

        // event-related props
        configBuilder
                .with(DebeziumConstants.MAX_BATCH_SIZE, props.getMaxBatchSize())
                .with(DebeziumConstants.MAX_QUEUE_SIZE, props.getMaxQueueSize())
                .with(DebeziumConstants.POLL_INTERVAL_MS, props.getPollIntervalMs())
                .with(DebeziumConstants.SCHEMA_REFRESH_MODE, props.getSchemaRefreshMode());

        return configBuilder.build();
    }

    /**
     * Prefix tables to include with dbname if not prefixed
     */
    private String prepareTableList(List<String> tables) {
        return Optional.ofNullable(tables)
                .filter(t -> !t.isEmpty())
                .map(t -> {
                    String tablePrefix = StringUtils.isNotBlank(props.getDbName()) ? props.getDbName() + "." : "";
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