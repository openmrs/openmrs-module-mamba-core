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

import io.debezium.DebeziumException;
import io.debezium.engine.ChangeEvent;
import org.apache.kafka.connect.data.Struct;
import org.apache.kafka.connect.source.SourceRecord;

import java.time.Instant;
import java.util.Optional;
import java.util.function.Function;

/**
 * A mapper utility class; to map a Debezium {@link ChangeEvent} to a {@link DbCrudEvent}.
 **/
public class DbChangeToEventMapper
        implements Function<ChangeEvent<SourceRecord, SourceRecord>, DbEvent> {

    private static final String BEFORE_FIELD = "before";
    private static final String AFTER_FIELD = "after";
    private static final String SOURCE_FIELD = "source";
    private static final String OPERATION_FIELD = "op";
    private static final String DDL_FIELD = "ddl";
    private static final String SCHEMA_CHANGES_FIELD = "schemaChange";
    private static final String TIMESTAMP_FIELD = "ts_ms";
    private static final String SNAPSHOT_FIELD = "snapshot";
    private static final String TABLE_FIELD = "table";
    private static final String NAME_FIELD = "name";

    @Override
    public DbEvent apply(ChangeEvent<SourceRecord, SourceRecord> changeEvent) {

        SourceRecord record = extractRecord(changeEvent);
        Struct valueStruct = getStruct(record.value(), "value");
        Struct sourceStruct = valueStruct.getStruct(SOURCE_FIELD);

        validateKeyStruct(getStruct(record.key(), "key"));

        boolean isSchemaChangeEvent = valueStruct.schema().field(DDL_FIELD) != null || valueStruct.schema().field(SCHEMA_CHANGES_FIELD) != null;
        DbOperation operation = determineOperation(valueStruct, isSchemaChangeEvent);

        ObjectMap primaryKey = new ObjectMapImpl(getStruct(record.key(), "key"));
        String primaryKeyName = primaryKey.keySet().iterator().next();
        Object primaryKeyValue = primaryKey.get(primaryKeyName);

        ObjectMap parsedPK = new ObjectMapImpl();
        parsedPK.put("id", primaryKeyValue);

        ObjectMap previousState = extractPreviousState(valueStruct, operation);
        ObjectMap newState = extractNewState(valueStruct, operation);

        ObjectMap source = new ObjectMapImpl(sourceStruct);
        ObjectMap values = (operation == DbOperation.DELETE) ? previousState : newState;

        Long timestamp = Optional.ofNullable(sourceStruct.schema().field(TIMESTAMP_FIELD) != null ? sourceStruct.getInt64(TIMESTAMP_FIELD) : null)
                .orElseThrow(() -> new DebeziumException("Timestamp is missing"));

        if (isSchemaChangeEvent) {
            return buildSchemaEvent(parsedPK, operation, previousState, newState, source, values, timestamp);
        } else {
            return buildCrudEvent(parsedPK, valueStruct, operation, previousState, newState, source, values, timestamp);
        }
    }

    private DbSchemaEvent buildSchemaEvent(ObjectMap primaryKey, DbOperation operation, ObjectMap previousState, ObjectMap newState,
                                           ObjectMap source, ObjectMap values, Long timestamp) {
        return new DbSchemaEvent.Builder()
                .primaryKey(primaryKey)
                .operation(operation)
                .previousState(previousState)
                .newState(newState)
                .timestamp(Instant.ofEpochMilli(timestamp))
                .values(values)
                .source(source)
                .build();
    }

    private DbCrudEvent buildCrudEvent(ObjectMap primaryKey, Struct valueStruct, DbOperation operation,
                                       ObjectMap previousState, ObjectMap newState, ObjectMap source, ObjectMap values, Long timestamp) {
        return new DbCrudEvent.Builder()
                .primaryKey(primaryKey)
                .tableName(valueStruct.getStruct(SOURCE_FIELD).getString(TABLE_FIELD))
                .operation(operation)
                .previousState(previousState)
                .newState(newState)
                .snapshot(DbSnapshot.convertToEnum(valueStruct.getStruct(SOURCE_FIELD).getString(SNAPSHOT_FIELD)))
                .timestamp(Instant.ofEpochMilli(timestamp))
                .values(values)
                .source(source)
                .sourceName(valueStruct.getStruct(SOURCE_FIELD).getString(NAME_FIELD))
                .build();
    }

    private ObjectMap extractPreviousState(Struct valueStruct, DbOperation operation) {
        return (operation == DbOperation.DELETE || operation == DbOperation.UPDATE)
                ? new ObjectMapImpl(Optional.ofNullable(valueStruct.getStruct(BEFORE_FIELD)).orElse(new Struct(valueStruct.schema())))
                : new ObjectMapImpl();
    }

    private ObjectMap extractNewState(Struct valueStruct, DbOperation operation) {
        return (operation == DbOperation.CREATE || operation == DbOperation.UPDATE)
                ? new ObjectMapImpl(Optional.ofNullable(valueStruct.getStruct(AFTER_FIELD)).orElse(new Struct(valueStruct.schema())))
                : new ObjectMapImpl();
    }

    private DbOperation determineOperation(Struct valueStruct, boolean isSchemaChange) {
        DbOperation operation;
        if (isSchemaChange) {
            operation = valueStruct.schema().field(DDL_FIELD) != null ? DbOperation.ALTER : DbOperation.UNKNOWN; // You can fine-tune this
        } else {
            String operationField = valueStruct.getString(OPERATION_FIELD);
            operation = operationField != null ? DbOperation.convertToEnum(operationField) : DbOperation.UNKNOWN;
        }
        return operation;
    }

    private SourceRecord extractRecord(ChangeEvent<SourceRecord, SourceRecord> changeEvent) {
        return Optional.ofNullable(changeEvent)
                .map(ChangeEvent::value)
                .orElseThrow(() -> new DebeziumException("ChangeEvent value is null"));
    }

    /**
     * Helper method to retrieve a {@link Struct} and throw an appropriate exception if it is null.
     */
    private Struct getStruct(Object object, String structName) {
        return Optional.ofNullable((Struct) object)
                .orElseThrow(() -> new DebeziumException(structName + " struct is null"));
    }

    /**
     * Validates the {@link Struct} for the key, ensuring it contains a single primary key.
     */
    private void validateKeyStruct(Struct keyStruct) {
        int keyFieldsSize = keyStruct.schema().fields().size();
        if (keyFieldsSize == 0) {
            throw new DebeziumException("Tables without a primary key are not supported");
        }
        if (keyFieldsSize > 1) {
            throw new DebeziumException("Tables with composite primary keys are not supported");
        }
    }
}