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

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.MambaReportService;
import org.openmrs.module.mambacore.api.model.MambaReportItem;
import org.openmrs.module.mambacore.api.model.MambaReportPagination;
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Enumeration;
import java.util.List;

@Resource(name = RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE + "/report",
        supportedClass = MambaReportItem.class,
        supportedOpenmrsVersions = {"2.0 - 9.*"})
public class MambaReportResource implements Searchable {

    private static final Logger log = LoggerFactory.getLogger(MambaReportResource.class);

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }

    @Override
    public SimpleObject search(RequestContext context) throws ResponseException {

        context.setLimit(10);
        context.setStartIndex(0);

        MambaReportCriteria searchCriteria = new MambaReportCriteria();
        Integer pageSize = searchCriteria.getPageSize(); //defaults
        Integer pageNumber = searchCriteria.getPageNumber(); //defaults

        Enumeration<String> parameterNames = context.getRequest().getParameterNames();
        while (parameterNames.hasMoreElements()) {

            String paramName = parameterNames.nextElement();
            String paramValue = context.getRequest().getParameter(paramName);

            log.debug("search API hit with param: {} vale: {}", paramName, paramValue);

            switch (paramName) {
                case "report_id":
                    searchCriteria.setReportId(paramValue);
                    break;
                case "page_number":
                    pageNumber = Integer.parseInt(paramValue);
                    searchCriteria.setPageNumber(pageNumber);
                    break;
                case "page_size":
                    pageSize = Integer.parseInt(paramValue);
                    searchCriteria.setPageSize(pageSize);
                    break;
                default:
                    searchCriteria.getSearchFields().add(new MambaReportSearchField(paramName, paramValue));
                    break;
            }
        }

        if (searchCriteria.getReportId() == null) {
            return new EmptySearchResult().toSimpleObject(null);
        }

        ObjectMapper objectMapper = new ObjectMapper();

        //TODO: Delete after Testing
        try {
            String argumentsJson = objectMapper.writeValueAsString(searchCriteria);
            log.debug("Mamba search criteria before passing it over: {}", argumentsJson);
            System.out.println("Mamba search criteria before passing it over sysout: " + argumentsJson);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        List<MambaReportItem> mambaReportItems = getService()
                .getMambaReportByCriteria(searchCriteria);

        Integer totalRecords = getService()
                .getMambaReportSize(searchCriteria);

        System.out.println("Total records: " + totalRecords);
        System.out.println("fetched records: " + mambaReportItems.size());

        Integer totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        MambaReportPagination pagination = new MambaReportPagination();
        pagination.setPageNumber(pageNumber);
        pagination.setPageSize(pageSize);
        pagination.setTotalRecords(totalRecords);
        pagination.setTotalPages(totalPages);

        return new SimpleObject()
                .add("results", mambaReportItems)
                .add("pagination", pagination);
    }

    @Override
    public String getUri(Object o) {
        return null;
    }
}
