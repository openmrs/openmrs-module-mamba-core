/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.web.resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.MambaReportService;
import org.openmrs.module.mambacore.api.model.MambaReportItem;
import org.openmrs.module.mambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.mambacore.api.parameter.MambaReportSearchField;
import org.openmrs.module.mambacore.web.controller.MambaReportRestController;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.resource.api.Searchable;
import org.openmrs.module.webservices.rest.web.resource.impl.EmptySearchResult;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.Enumeration;
import java.util.List;

@Resource(name = RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE + "/report", supportedClass = MambaReportItem.class, supportedOpenmrsVersions = {"2.0 - 2.*"})
public class MambaReportResource implements Searchable {

    private static Logger log = LoggerFactory.getLogger(MambaReportResource.class);

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }

    @Override
    public SimpleObject search(RequestContext context) throws ResponseException {

        context.setLimit(10);
        context.setStartIndex(0);

        MambaReportCriteria searchCriteria = new MambaReportCriteria();

        Enumeration<String> parameterNames = context.getRequest().getParameterNames();
        while (parameterNames.hasMoreElements()) {

            String paramName = parameterNames.nextElement();
            String paramValue = context.getRequest().getParameter(paramName);

            log.debug("search API hit with param: {} vale: {}", paramName, paramValue);

            if (paramName.equals("report_id")) {
                searchCriteria.setReportId(paramValue);
            } else {
                searchCriteria.getSearchFields().add(new MambaReportSearchField(paramName, paramValue));
            }
        }

        if (searchCriteria.getReportId() == null) {
            return new EmptySearchResult().toSimpleObject(null);
        }

        List<MambaReportItem> mambaReportItems = getService().getMambaReportByCriteria(searchCriteria);
        return new SimpleObject().add("results", mambaReportItems);
    }

    @Override
    public String getUri(Object o) {
        return null;
    }
}
