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

public final class DbSchemaEvent implements DbEvent {

    private final ObjectMap primaryKey;
    private final DbOperation operation;
    private final ObjectMap previousState;
    private final ObjectMap newState;
    private final Instant timestamp;
    private final ObjectMap values;
    private final ObjectMap source;

    private DbSchemaEvent(Builder builder) {
        this.primaryKey = Objects.requireNonNull(builder.primaryKey, "primaryKey cannot be null");
        this.operation = Objects.requireNonNull(builder.operation, "operation cannot be null");
        this.previousState = builder.previousState;
        this.newState = builder.newState;
        this.timestamp = Objects.requireNonNull(builder.timestamp, "timestamp cannot be null");
        this.values = Objects.requireNonNull(builder.values, "values cannot be null");
        this.source = Objects.requireNonNull(builder.source, "source cannot be null");
    }

    public ObjectMap getPrimaryKey() {
        return primaryKey;
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

    public Instant getTimestamp() {
        return timestamp;
    }

    public ObjectMap getValues() {
        return values;
    }

    public ObjectMap getSource() {
        return source;
    }

    @Override
    public boolean isSchemaEvent() {
        return true;
    }

    @Override
    public String toString() {
        return "DbSchemaEvent{" +
                "primaryKey=" + primaryKey +
                ", operation=" + operation +
                ", previousState=" + previousState +
                ", newState=" + newState +
                ", timestamp=" + timestamp +
                ", values=" + values +
                ", source=" + source + '\'' +
                '}';
    }

    public static class Builder {
        private ObjectMap primaryKey;
        private DbOperation operation;
        private ObjectMap previousState;
        private ObjectMap newState;
        private Instant timestamp;
        private ObjectMap values;
        private ObjectMap source;

        public Builder primaryKey(ObjectMap primaryKey) {
            this.primaryKey = primaryKey;
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

        public DbSchemaEvent build() {
            return new DbSchemaEvent(this);
        }
    }
}