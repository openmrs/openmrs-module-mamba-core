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

import java.util.Map;

/**
 * Simple HashMap extension that contains utility methods for retrieving / converting values to certain types
 */
public interface ObjectMap extends Map<String, Object> {

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
        if (value == null) {
            return null;
        } else if (value instanceof Boolean) {
            return (Boolean) value;
        } else if (value instanceof Number) {
            return ((Number) value).intValue() == 1;
        } else {
            return Boolean.parseBoolean(value.toString());
        }
    }

    /**
     * @return the value with the given key as a cast or parsed boolean value, or the defaultValue if null
     */
    default boolean getBoolean(String key, boolean defaultValue) {
        Boolean value = getBoolean(key);
        return value == null ? defaultValue : value;
    }
}