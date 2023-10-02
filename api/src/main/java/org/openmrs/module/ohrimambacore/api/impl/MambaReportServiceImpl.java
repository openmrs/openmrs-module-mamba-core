package org.openmrs.module.ohrimambacore.api.impl;

import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.ohrimambacore.api.MambaReportService;
import org.openmrs.module.ohrimambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * @author smallGod
 * date: 09/07/2023
 */
@Transactional
public class MambaReportServiceImpl extends BaseOpenmrsService implements MambaReportService {

    private MambaReportItemDao dao;

     public void setDao(MambaReportItemDao dao) {
        this.dao = dao;
    }

    @Override
    //@Transactional(readOnly = true)
    public List<MambaReportItem>  getMambaReport(String mambaReportId) {
        return dao.getMambaReport(mambaReportId);
    }

    @Override
    //@Transactional(readOnly = true)
    public List<MambaReportItem> getMambaReportByCriteria(MambaReportCriteria criteria) {
        return dao.getMambaReport(criteria);
    }
}
