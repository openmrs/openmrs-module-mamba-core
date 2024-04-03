/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api.dao;

import org.openmrs.module.mambacore.api.model.MambaReportItem;
import org.openmrs.module.mambacore.api.parameter.MambaReportCriteria;

import java.util.List;

public interface MambaReportItemDao {

    /**
     * Gets a MambaReport by the report ID
     *
     * @param mambaReportId the MambaReport id
     * @return a list of MambaReport items with given id, or null if none exists
     */
    List<MambaReportItem> getMambaReport(String mambaReportId);

    /**
     * Gets all MambaReport results that match the given criteria
     *
     * @param criteria - the criteria for the returned MambaReport results
     * @return a list of all MambaReport items
     */
    List<MambaReportItem> getMambaReport(MambaReportCriteria criteria);

}
