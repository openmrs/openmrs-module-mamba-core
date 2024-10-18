package com.ayinza.util.debezium.domain.model;

import com.ayinza.utils.domain.model.Contract;


import java.util.Map;

/**
 * Simple HashMap extension that contains utility methods for retrieving / converting values to certain types
 */
public interface ObjectMap extends Contract<ObjectMap>, Map<String, Object> {

    /**
     * @return the value with the given key cast as an Integer
     */
    default Integer getInteger(String key) {
        return (Integer) get(key);
    }

    /**
     * @return the value with the given key cast as a Long
     */
    default Long getLong(String key) {
        return (Long) get(key);
    }

    /**
     * @return the toString representation of the value with the given key, or null if not found
     */
    default String getString(String key) {
        Object value = get(key);
        return value == null ? null : value.toString();
    }

    /**
     * @return the value with the given key as a cast or parsed boolean value
     */
    default Boolean getBoolean(String key) {
        Object value = get(key);
        return switch (value) {
            case null -> null;
            case Boolean bool -> bool;
            case Number number -> number.intValue() == 1;
            default -> Boolean.parseBoolean(value.toString());
        };
    }

    /**
     * @return the value with the given key as a cast or parsed boolean value, or the defaultValue if null
     */
    default boolean getBoolean(String key, boolean defaultValue) {
        Boolean value = getBoolean(key);
        return value == null ? defaultValue : value;
    }
}