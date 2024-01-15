package org.openmrs.module.ohrimambacore.api.parameter;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * date: 09/07/2023
 */
public class MambaReportSearchField implements Serializable {

    private static final long serialVersionUID = -5995274582315599409L;

    @JsonProperty("column")
    private String column;

    @JsonProperty("operator")
    private String operator;

    @JsonProperty("value")
    private String value;

    @JsonProperty("logical_operator")
    private String logicalOperator;

    public MambaReportSearchField() {
    }

    public MambaReportSearchField(String column, String value) {
        this(column, "=", value, "=");
    }

    public MambaReportSearchField(String column, String operator, String value, String logicalOperator) {
        this.column = column;
        this.operator = operator;
        this.value = value;
        this.logicalOperator = logicalOperator;
    }

    public String getColumn() {
        return column;
    }

    public void setColumn(String column) {
        this.column = column;
    }

    public String getOperator() {
        return operator;
    }

    public void setOperator(String operator) {
        this.operator = operator;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getLogicalOperator() {
        return logicalOperator;
    }

    public void setLogicalOperator(String logicalOperator) {
        this.logicalOperator = logicalOperator;
    }
}
