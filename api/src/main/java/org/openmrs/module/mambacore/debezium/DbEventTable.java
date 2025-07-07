package org.openmrs.module.mambacore.debezium;


import java.util.Arrays;

/**
 * Enum representing all the Tables we capture Events on.
 * This enum provides conversion functionality and encapsulates Table names.
 *
 */
public enum DbEventTable  {

    OBS("obs"),
    ENCOUNTER("encounter"),
    UNKNOWN("unknown");

    private final String value;

    DbEventTable(String value) {
        this.value = value;
    }

    /**
     * Converts the provided string to a corresponding {@link DbEventTable} enum.
     * If the value is null or unrecognized, {@link DbEventTable#UNKNOWN} is returned.
     *
     * @param value the string representation of the snapshot status
     * @return the matching {@link DbEventTable} enum, or {@link DbEventTable#UNKNOWN} if none matches
     */
    public static DbEventTable convertToEnum(String value) {
        return Arrays.stream(DbEventTable.values())
                .filter(enumConstant -> enumConstant.value.equalsIgnoreCase(value))
                .findFirst()
                .orElse(DbEventTable.UNKNOWN);
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