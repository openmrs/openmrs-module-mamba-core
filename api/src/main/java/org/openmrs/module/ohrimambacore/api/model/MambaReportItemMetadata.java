package org.openmrs.module.ohrimambacore.api.model;

import java.io.Serializable;

/**
 * date: 09/07/2023
 */
public class MambaReportItemMetadata implements Serializable {
	
	private static final long serialVersionUID = 4717202824335181555L;
	
	private Integer serialId;
	
	public MambaReportItemMetadata() {
	}
	
	public MambaReportItemMetadata(Integer serialId) {
		this.serialId = serialId;
	}
	
	public Integer getSerialId() {
		return serialId;
	}
	
	public void setSerialId(Integer serialId) {
		this.serialId = serialId;
	}
}
