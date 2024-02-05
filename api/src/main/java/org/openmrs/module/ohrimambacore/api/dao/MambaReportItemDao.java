package org.openmrs.module.ohrimambacore.api.dao;

import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;

import java.util.List;

/**
 * @author smallGod
 * date: 09/07/2023
 */
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
