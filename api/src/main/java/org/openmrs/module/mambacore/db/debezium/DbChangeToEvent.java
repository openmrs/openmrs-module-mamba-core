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

import io.debezium.DebeziumException;
import io.debezium.engine.ChangeEvent;
import org.apache.kafka.connect.data.Struct;
import org.apache.kafka.connect.source.SourceRecord;

import java.util.Optional;
import java.util.function.Function;

/**
 * Utility function that converts a Debezium {@link ChangeEvent} to a {@link DbEvent}.
 */
public class DbChangeToEvent
        implements Function<ChangeEvent<SourceRecord, SourceRecord>, DbEvent> {

    private static final String BEFORE_FIELD = "before";
    private static final String AFTER_FIELD = "after";
    private static final String SOURCE_FIELD = "source";
    private static final String OPERATION_FIELD = "op";
    private static final String TIMESTAMP_FIELD = "ts_ms";
    private static final String SNAPSHOT_FIELD = "snapshot";
    private static final String TABLE_FIELD = "table";
    private static final String NAME_FIELD = "name";

    @Override
    public DbEvent apply(ChangeEvent<SourceRecord, SourceRecord> changeEvent) {

        SourceRecord record = Optional.ofNullable(changeEvent)
                .map(ChangeEvent::value)
                .orElseThrow(() -> new DebeziumException("ChangeEvent value is null"));

        Struct keyStruct = getStruct(record.key(), "key");
        Struct valueStruct = getStruct(record.value(), "value");
        Struct sourceStruct = getStruct(valueStruct, SOURCE_FIELD);

        validateKeyStruct(keyStruct);

        ObjectMap primaryKey = new ObjectMapImpl(keyStruct);
        ObjectMap previousState = new ObjectMapImpl(valueStruct.getStruct(BEFORE_FIELD));
        ObjectMap newState = new ObjectMapImpl(valueStruct.getStruct(AFTER_FIELD));
        ObjectMap source = new ObjectMapImpl(sourceStruct);

        DbOperation operation = DbOperation.convertToEnum(getString(valueStruct, OPERATION_FIELD));
        ObjectMap values = (operation == DbOperation.DELETE) ? previousState : newState;

        Long timestamp = getLong(valueStruct, TIMESTAMP_FIELD);
        String tableName = getString(sourceStruct, TABLE_FIELD);
        String sourceName = getString(sourceStruct, NAME_FIELD);
        DbSnapshot snapshot = DbSnapshot.convertToEnum(getString(sourceStruct, SNAPSHOT_FIELD));

        return new DbEvent(primaryKey,
                previousState,
                newState,
                source,
                values,
                tableName,
                sourceName,
                operation,
                timestamp,
                snapshot);
    }

    /**
     * Helper method to retrieve a {@link Struct} and throw an appropriate exception if it is null.
     */
    private Struct getStruct(Object object, String structName) {
        return Optional.ofNullable((Struct) object)
                .orElseThrow(() -> new DebeziumException(structName + " struct is null"));
    }

    /**
     * Helper method to retrieve a String field value from a {@link Struct}.
     */
    private String getString(Struct struct, String fieldName) {
        return Optional.ofNullable(struct.getString(fieldName))
                .orElseThrow(() -> new DebeziumException(fieldName + " field is missing or null"));
    }

    /**
     * Helper method to retrieve a Long field value from a {@link Struct}.
     */
    private Long getLong(Struct struct, String fieldName) {
        return Optional.ofNullable(struct.getInt64(fieldName))
                .orElseThrow(() -> new DebeziumException(fieldName + " field is missing or null"));
    }

    /**
     * Validates the {@link Struct} for the key, ensuring it contains a single primary key.
     */
    private void validateKeyStruct(Struct keyStruct) {

        int keyFieldsSize = keyStruct.schema().fields().size();

        if (keyFieldsSize == 0) {
            throw new DebeziumException("Tables with no primary key column are not supported");
        }

        if (keyFieldsSize > 1) {
            throw new DebeziumException("Tables with composite primary keys are not supported");
        }
    }
}