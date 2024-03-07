/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ohrimambacore.api.dao;

import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;

import java.util.List;

public interface MambaReportItemDao {

    /**
     * Gets a MambaReport by the report ID
     *
     * @param mambaReportId the MambaReport id
     * @return the MambaReport with given id, or null if none exists
     */
    List<MambaReportItem>  getMambaReport(String mambaReportId);

    /**
     * Gets all OrderTemplate results that match the given criteria
     *
     * @param criteria - the criteria for the returned OrderTemplate results
     * @return a list of OrderTemplates
     */
    List<MambaReportItem> getMambaReport(MambaReportCriteria criteria);

}
