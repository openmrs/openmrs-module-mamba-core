/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api.parameter;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class MambaReportCriteria implements Serializable {

    private static final long serialVersionUID = 6717202824335189575L;

    @JsonProperty("report_id")
    private String reportId;

    @JsonProperty("arguments")
    private List<MambaReportSearchField> searchFields = new ArrayList<>();

    public MambaReportCriteria() {
        this(null);
    }

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
