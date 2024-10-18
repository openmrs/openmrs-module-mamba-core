package com.ayinza.util.debezium.application.model;

import com.ayinza.utils.domain.model.debezium.ObjectMap;
import org.apache.kafka.connect.data.Field;
import org.apache.kafka.connect.data.Struct;

import java.util.HashMap;

public class ObjectMapImpl extends HashMap<String, Object> implements ObjectMap {

    public ObjectMapImpl() {
        super();
    }

    /**
     * Constructs a new ObjectMap from the given Struct, using the fields of the schema as keys
     *
     * @param struct the struct to convert to an ObjectMap
     */
    public ObjectMapImpl(Struct struct) {
        this();
        if (struct != null && struct.schema() != null) {
            for (Field field : struct.schema().fields()) {
                put(field.name(), struct.get(field));
            }
        }
    }

    @Override
    public ObjectMapImpl fromContract() {
        return this;
    }
}
