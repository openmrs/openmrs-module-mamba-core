/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api.model;

import java.io.Serializable;

public class MambaReportItemMetadata implements Serializable {
	
	private static final long serialVersionUID = 4717202824335189555L;
	
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
