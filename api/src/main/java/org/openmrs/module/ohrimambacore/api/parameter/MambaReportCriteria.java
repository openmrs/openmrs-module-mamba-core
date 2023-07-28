package org.openmrs.module.ohrimambacore.api.parameter;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * @author smallGod date: 09/07/2023
 */
public class MambaReportCriteria implements Serializable {

    @JsonProperty("report_id")
    private String reportId;

    @JsonProperty("arguments")
    private List<MambaReportSearchField> searchFields = new ArrayList<>();

    public MambaReportCriteria(String reportId) {
        this.reportId = reportId;
    }

    public String getReportId() {
        return reportId;
    }

    public void setReportId(String reportId) {
        this.reportId = reportId;
    }

    public List<MambaReportSearchField> getSearchFields() {
        return searchFields;
    }

    public void setSearchFields(List<MambaReportSearchField> searchFields) {
        this.searchFields = searchFields;
    }
}
