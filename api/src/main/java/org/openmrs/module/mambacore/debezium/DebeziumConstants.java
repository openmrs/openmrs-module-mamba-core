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

public class DebeziumConstants {

    // General properties
    public static final String NAME = "name";

    // Database-related properties
    public static final String DB_HOST = "database.hostname";
    public static final String DB_PORT = "database.port";
    public static final String DB_NAME = "database.name";
    public static final String DB_USERNAME = "database.user";
    public static final String DB_PASSWORD = "database.password";
    public static final String DB_SERVER_ID = "database.server.id";
    public static final String DB_SERVER_NAME = "database.server.name";
    public static final String DB_INCLUDE_LIST = "database.include.list";
    public static final String DB_EXCLUDE_LIST = "database.exclude.list";
    public static final String DATABASE_TIMEZONE = "database.timezone";
    public static final String DATABASE_HISTORY = "database.history";

    public static final String SCHEMA_HISTORY_INTERNAL = "schema.history.internal";
    public static final String SCHEMA_HISTORY_INTERNAL_FILE = "schema.history.internal.file.filename";

    public static final String TABLE_INCLUDE_LIST = "table.include.list";
    public static final String TABLE_EXCLUDE_LIST = "table.exclude.list";
    public static final String COLUMN_BLACKLIST = "column.blacklist";
    public static final String COLUMN_WHITELIST = "column.whitelist";

    // Offset storage-related properties
    public static final String OFFSET_STORAGE_FILE_NAME = "offset.storage.file.name";
    public static final String OFFSET_STORAGE_DIR = "offset.storage.rocksdb.dir";
    public static final String OFFSET_STORAGE = "offset.storage";
    public static final String OFFSET_STORAGE_IMPL = "offset.storage.impl";
    public static final String OFFSET_FLUSH_INTERVAL_MS = "offset.flush.interval.ms";
    public static final String OFFSET_FLUSH_TIMEOUT_MS = "offset.flush.timeout.ms";
    public static final String OFFSET_FLUSH_SIZE = "offset.flush.size";

    // Snapshot-related properties
    public static final String SNAPSHOT_MODE = "snapshot.mode";
    public static final String SNAPSHOT_LOCKING_MODE = "snapshot.locking.mode";
    public static final String SNAPSHOT_FETCH_SIZE = "snapshot.fetch.size";
    public static final String SNAPSHOT_INCLUDE_COLLECTION_LIST = "snapshot.include.collection.list";
    public static final String SNAPSHOT_EXCLUDE_COLLECTION_LIST = "snapshot.exclude.collection.list";
    public static final String SNAPSHOT_DELAY_MS = "snapshot.delay.ms";

    // Connector-related properties
    public static final String CONNECTOR_CLASS = "connector.class";
    public static final String DATABASE_HISTORY_IMPL = "database.history.impl";
    public static final String DATABASE_HISTORY_FILE_NAME = "database.history.file.name";

    // Heartbeat properties
    public static final String HEARTBEAT_INTERVAL_MS = "heartbeat.interval.ms";
    public static final String HEARTBEAT_TOPICS_PREFIX = "heartbeat.topics.prefix";

    // Event-related properties
    public static final String MAX_BATCH_SIZE = "max.batch.size";
    public static final String MAX_QUEUE_SIZE = "max.queue.size";
    public static final String POLL_INTERVAL_MS = "poll.interval.ms";
    public static final String SCHEMA_REFRESH_MODE = "schema.refresh.mode";
    public static final String TOMBSTONES_ON_DELETE = "tombstones.on.delete";
    public static final String PROVIDE_TRANSACTION_METADATA = "provide.transaction.metadata";

    // Error handling-related properties
    public static final String MAX_RETRIES = "max.retries";
    public static final String RETRY_DELAY_MS = "retry.delay.ms";
    public static final String MAX_RETRY_DURATION_MS = "max.retry.duration.ms";

    // Additional general configurations
    public static final String INCLUDE_SCHEMA_CHANGES = "include.schema.changes";
    public static final String INCLUDE_QUERY = "include.query";
    public static final String DECIMAL_HANDLING_MODE = "decimal.handling.mode";
    public static final String BINARY_HANDLING_MODE = "binary.handling.mode";

    // Other constants can be added here as needed
    public static final String TOPIC_PREFIX = "topic.prefix";
}
