package com.ayinza.util.debezium.domain.model;

/**
 * @author smallGod
 * @date: 16/10/2024
 */
public enum DbSnapshot implements ValueObject<DbSnapshot> {

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

    @Override
    public boolean isSameAs(DbSnapshot other) {
        return this.value.equalsIgnoreCase(other.value);
    }
}
