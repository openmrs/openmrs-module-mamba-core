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

import java.util.Arrays;

/**
 * Enum representing the snapshot status of a database operation.
 * This enum provides conversion functionality and encapsulates snapshot states.
 *
 * @since 2024-10-10
 */
public enum DbSnapshot {

    TRUE("true"),
    FALSE("false"),
    LAST("last"),
    UNKNOWN("unknown");

    private final String value;

    DbSnapshot(String value) {
        this.value = value;
    }

    /**
     * Converts the provided string to a corresponding {@link DbSnapshot} enum.
     * If the value is null or unrecognized, {@link DbSnapshot#UNKNOWN} is returned.
     *
     * @param value the string representation of the snapshot status
     * @return the matching {@link DbSnapshot} enum, or {@link DbSnapshot#UNKNOWN} if none matches
     */
    public static DbSnapshot convertToEnum(String value) {
        return Arrays.stream(DbSnapshot.values())
                .filter(enumConstant -> enumConstant.value.equalsIgnoreCase(value))
                .findFirst()
                .orElse(DbSnapshot.UNKNOWN);
    }

    /**
     * Retrieves the string value associated with the enum constant.
     *
     * @return the string representation of the enum constant
     */
    public String getValue() {
        return value;
    }
}