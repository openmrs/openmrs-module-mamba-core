package com.ayinza.util.debezium.domain.model;

/**
 * @author smallGod
 * @date: 16/10/2024
 */
public enum DbOperation implements ValueObject<DbOperation> {

    CREATE("c"),
    READ("r"),
    UPDATE("u"),
    DELETE("d");

    private final String value;

    DbOperation(String value) {
        this.value = value;
    }

    public static DbOperation convertToEnum(String value)
            throws EnumConstantNotPresentException {

        for (DbOperation enumConstant : DbOperation.values()) {
            if (value.equalsIgnoreCase(enumConstant.getValue()))
                return enumConstant;
        }
        throw new EnumConstantNotPresentException(DbOperation.class, value);
    }

    public String getValue() {
        return this.value;
    }

    @Override
    public boolean isSameAs(DbOperation other) {
        return this.value.equalsIgnoreCase(other.value);
    }
}
