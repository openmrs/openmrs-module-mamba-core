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
