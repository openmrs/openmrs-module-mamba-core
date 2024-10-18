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

public class DbEvent {

    private final ObjectMap primaryKey;

    private final String tableName;

    private final DbOperation operation;

    private final ObjectMap previousState;

    private final ObjectMap newState;

    private final DbSnapshot snapshot;

    private final Long timestamp;

    private final ObjectMap values;

    private final ObjectMap source;

    private final String sourceName;

    public DbEvent(
            ObjectMap primaryKey,
            ObjectMap previousState,
            ObjectMap newState,
            ObjectMap source,
            ObjectMap values,
            String tableName,
            String sourceName,
            DbOperation operation,
            Long timestamp,
            DbSnapshot snapshot) {

        this.primaryKey = primaryKey;
        this.previousState = previousState;
        this.newState = newState;
        this.source = source;
        this.values = values;
        this.tableName = tableName;
        this.operation = operation;
        this.timestamp = timestamp;
        this.snapshot = snapshot;
        this.sourceName = sourceName;
    }

    public ObjectMap getPrimaryKeyId() {
        return primaryKey;
    }

    public String getTableName() {
        return tableName;
    }

    public DbOperation getOperation() {
        return operation;
    }

    public ObjectMap getPreviousState() {
        return previousState;
    }

    public ObjectMap getNewState() {
        return newState;
    }

    public DbSnapshot getSnapshot() {
        return snapshot;
    }

    public Long getTimestamp() {
        return timestamp;
    }

    public ObjectMap getPrimaryKey() {
        return primaryKey;
    }

    public ObjectMap getValues() {
        return values;
    }

    public ObjectMap getSource() {
        return source;
    }
}
