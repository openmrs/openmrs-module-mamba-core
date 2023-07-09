package org.openmrs.module.ohrimambacore.api.parameter;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author smallGod date: 09/07/2023
 */
public class MambaReportSearchField implements Serializable {

    private static final long serialVersionUID = -5995274582315599409L;

    @JsonProperty("field_name")
    private String fieldName;

    @JsonProperty("operator")
    private String operator;

    @JsonProperty("field_value")
    private String fieldValue;

    @JsonProperty("logical_operator")
    private String logicalOperator;

    public MambaReportSearchField() {
    }

    public MambaReportSearchField(String fieldName, String operator, String fieldValue, String logicalOperator) {
        this.fieldName = fieldName;
        this.operator = operator;
        this.fieldValue = fieldValue;
        this.logicalOperator = logicalOperator;
    }

    public String getFieldName() {
        return fieldName;
    }

    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public String getOperator() {
        return operator;
    }

    public void setOperator(String operator) {
        this.operator = operator;
    }

    public String getFieldValue() {
        return fieldValue;
    }

    public void setFieldValue(String fieldValue) {
        this.fieldValue = fieldValue;
    }

    public String getLogicalOperator() {
        return logicalOperator;
    }

    public void setLogicalOperator(String logicalOperator) {
        this.logicalOperator = logicalOperator;
    }
}
