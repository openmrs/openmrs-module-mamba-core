package com.ayinza.util.debezium.domain.model;

import com.ayinza.utils.domain.vo.DbOperation;
import com.ayinza.utils.domain.vo.DbSnapshot;

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
