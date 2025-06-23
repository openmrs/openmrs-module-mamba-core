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

import java.time.Instant;
import java.util.Objects;

public final class DbCrudEvent implements DbEvent {

    private final ObjectMap primaryKey;
    private final String tableName;
    private final DbOperation operation;
    private final ObjectMap previousState;
    private final ObjectMap newState;
    private final DbSnapshot snapshot;
    private final Instant timestamp;
    private final ObjectMap values;
    private final ObjectMap source;
    private final String sourceName;

    private DbCrudEvent(Builder builder) {
        this.primaryKey = Objects.requireNonNull(builder.primaryKey, "primaryKey cannot be null");
        this.tableName = Objects.requireNonNull(builder.tableName, "tableName cannot be null");
        this.operation = Objects.requireNonNull(builder.operation, "operation cannot be null");
        this.previousState = builder.previousState;
        this.newState = builder.newState;
        this.snapshot = builder.snapshot;
        this.timestamp = Objects.requireNonNull(builder.timestamp, "timestamp cannot be null");
        this.values = Objects.requireNonNull(builder.values, "values cannot be null");
        this.source = Objects.requireNonNull(builder.source, "source cannot be null");
        this.sourceName = Objects.requireNonNull(builder.sourceName, "sourceName cannot be null");
    }

    public ObjectMap getPrimaryKey() {
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

    public Instant getTimestamp() {
        return timestamp;
    }

    public ObjectMap getValues() {
        return values;
    }

    public ObjectMap getSource() {
        return source;
    }

    public String getSourceName() {
        return sourceName;
    }

    @Override
    public boolean isSchemaEvent() {
        return false;
    }

    @Override
    public String toString() {
        return "DbCrudEvent{" +
                "primaryKey=" + primaryKey +
                ", tableName='" + tableName + '\'' +
                ", operation=" + operation +
                ", previousState=" + previousState +
                ", newState=" + newState +
                ", snapshot=" + snapshot +
                ", timestamp=" + timestamp +
                ", values=" + values +
                ", source=" + source +
                ", sourceName='" + sourceName + '\'' +
                '}';
    }

    public static class Builder {
        private ObjectMap primaryKey;
        private String tableName;
        private DbOperation operation;
        private ObjectMap previousState;
        private ObjectMap newState;
        private DbSnapshot snapshot;
        private Instant timestamp;
        private ObjectMap values;
        private ObjectMap source;
        private String sourceName;

        public Builder primaryKey(ObjectMap primaryKey) {
            this.primaryKey = primaryKey;
            return this;
        }

        public Builder tableName(String tableName) {
            this.tableName = tableName;
            return this;
        }

        public Builder operation(DbOperation operation) {
            this.operation = operation;
            return this;
        }

        public Builder previousState(ObjectMap previousState) {
            this.previousState = previousState;
            return this;
        }

        public Builder newState(ObjectMap newState) {
            this.newState = newState;
            return this;
        }

        public Builder snapshot(DbSnapshot snapshot) {
            this.snapshot = snapshot;
            return this;
        }

        public Builder timestamp(Instant timestamp) {
            this.timestamp = timestamp;
            return this;
        }

        public Builder values(ObjectMap values) {
            this.values = values;
            return this;
        }

        public Builder source(ObjectMap source) {
            this.source = source;
            return this;
        }

        public Builder sourceName(String sourceName) {
            this.sourceName = sourceName;
            return this;
        }

        public DbCrudEvent build() {
            return new DbCrudEvent(this);
        }
    }
}