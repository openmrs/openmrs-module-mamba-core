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

public enum DbSnapshot {

    TRUE("true"),
    FALSE("false"),
    LAST("last");

    private final String value;

    DbSnapshot(String value) {
        this.value = value;
    }

    public static DbSnapshot convertToEnum(String value)
            throws EnumConstantNotPresentException {

        for (DbSnapshot enumConstant : DbSnapshot.values()) {
            if (value.equalsIgnoreCase(enumConstant.getValue()))
                return enumConstant;
        }
        throw new EnumConstantNotPresentException(DbSnapshot.class, value);
    }

    public String getValue() {
        return this.value;
    }
}
