/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ohrimambacore.api.impl;

import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.ohrimambacore.api.MambaReportService;
import org.openmrs.module.ohrimambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Transactional
public class MambaReportServiceImpl extends BaseOpenmrsService implements MambaReportService {

    private MambaReportItemDao dao;

     public void setDao(MambaReportItemDao dao) {
        this.dao = dao;
    }

    @Override
    public List<MambaReportItem>  getMambaReport(String mambaReportId) {
        return dao.getMambaReport(mambaReportId);
    }

    @Override
    public List<MambaReportItem> getMambaReportByCriteria(MambaReportCriteria criteria) {
        return dao.getMambaReport(criteria);
    }
}
