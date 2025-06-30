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

import org.apache.kafka.connect.data.Field;
import org.apache.kafka.connect.data.Struct;

import java.util.HashMap;

public class ObjectMapImpl extends HashMap<String, Object> implements ObjectMap {

    public ObjectMapImpl() {
        super();
    }

    /**
     * Constructs a new ObjectMap from the given Struct,
     * using the fields of the schema as keys
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
}
