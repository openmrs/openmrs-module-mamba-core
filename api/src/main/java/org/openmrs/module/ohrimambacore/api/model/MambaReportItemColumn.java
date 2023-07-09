package org.openmrs.module.ohrimambacore.api.model;

import java.io.Serializable;

/**
 * @author smallGod date: 09/07/2023
 */
public class MambaReportItemColumn implements Serializable {
	
	private static final long serialVersionUID = -4302112399990406163L;
	
	private String column;
	
	private Object value;
	
	public MambaReportItemColumn() {
	}
	
	public MambaReportItemColumn(String column, Object value) {
		this.column = column;
		this.value = value;
	}
	
	public String getColumn() {
		return column;
	}
	
	public void setColumn(String column) {
		this.column = column;
	}
	
	public Object getValue() {
		return value;
	}
	
	public void setValue(Object value) {
		this.value = value;
	}
}
