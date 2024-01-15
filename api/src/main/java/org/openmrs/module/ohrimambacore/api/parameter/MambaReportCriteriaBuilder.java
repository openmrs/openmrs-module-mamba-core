/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ohrimambacore.api.parameter;

/**
 * date: 09/07/2023
 */
public class MambaReportCriteriaBuilder {
	
	private final MambaReportCriteria criteria;
	
	public MambaReportCriteriaBuilder(String reportId) {
		criteria = new MambaReportCriteria(reportId);
	}
	
	public MambaReportCriteriaBuilder setReportId(String reportId) {
		criteria.setReportId(reportId);
		return this;
	}
	
	public MambaReportCriteriaBuilder addSearchField(MambaReportSearchField searchField) {
		criteria.getSearchFields().add(searchField);
		return this;
	}
	
	public MambaReportCriteria build() {
		return criteria;
	}
}
