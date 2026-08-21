/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.web.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.MambaReportService;
import org.openmrs.module.mambacore.api.MambaReportsConstants;
import org.openmrs.module.mambacore.api.model.MambaReportItem;
import org.openmrs.module.mambacore.api.model.MambaReportPagination;
import org.openmrs.module.mambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.mambacore.api.parameter.MambaReportSearchField;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Spring MVC Controller for Mamba Report REST endpoints.
 * <p>
 * This approach completely avoids OpenMRS REST Web Services module dependencies
 * by using standard Spring MVC annotations and Java collections instead of
 * REST module classes like SimpleObject, @Resource, etc.
 * <p>
 * Endpoints:
 * - GET {REST_API_PATH}/report?report_id={id}&page_number={n}&page_size={size}
 * <p>
 * This implementation works across different OpenMRS REST Web Services versions
 * since it doesn't depend on the REST module's internal classes.
 */
@Controller
@RequestMapping(MambaReportsConstants.REST_API_PATH + "/report")
public class MambaReportRestController {

    private static final Logger log = LoggerFactory.getLogger(MambaReportRestController.class);

    private static final String DEFAULT_PAGE_SIZE = "50";
    private static final String DEFAULT_PAGE_NUMBER = "1";

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }

    /**
     * Search/retrieve Mamba report data based on criteria.
     * <p>
     * GET parameters:
     * - report_id (required): The report identifier
     * - page_number (optional): Page number, defaults to 1
     * - page_size (optional): Page size, defaults to 50
     * - Additional parameters are treated as search filters
     *
     * @param request      HTTP servlet request
     * @param reportId    The report identifier
     * @param pageNumber  Page number (default: 1)
     * @param pageSize    Page size (default: 50)
     * @return Map containing results and pagination (automatically converted to JSON)
     */
    @RequestMapping(method = RequestMethod.GET)
    public ResponseEntity<Map<String, Object>> getMambaReport(
            HttpServletRequest request,
            @RequestParam(value = "report_id", required = false) String reportId,
            @RequestParam(value = "page_number", required = false, defaultValue = DEFAULT_PAGE_NUMBER) Integer pageNumber,
            @RequestParam(value = "page_size", required = false, defaultValue = DEFAULT_PAGE_SIZE) Integer pageSize) {

        MambaReportCriteria searchCriteria = buildCriteriaFromRequest(request, reportId, pageNumber, pageSize);

        try {
            // Validate required parameters
            if (searchCriteria.getReportId() == null || searchCriteria.getReportId().trim().isEmpty()) {
                throw new IllegalArgumentException("report_id is required");
            }

            // Validate pagination parameters
            if (pageNumber != null && pageNumber < 1) {
                throw new IllegalArgumentException("page_number must be >= 1");
            }
            if (pageSize != null && pageSize <= 0) {
                throw new IllegalArgumentException("page_size must be > 0");
            }

            // Fetch results
            List<MambaReportItem> mambaReportItems = getService().getMambaReportByCriteria(searchCriteria);
            Integer totalRecords = getService().getMambaReportSize(searchCriteria);

            // Build pagination metadata
            MambaReportPagination pagination = buildPagination(searchCriteria, totalRecords);

            // Return response as Map (Spring MVC automatically converts to JSON)
            Map<String, Object> response = new HashMap<String, Object>();
            response.put("results", mambaReportItems);
            response.put("pagination", pagination);
            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            // Client errors - return 400 Bad Request
            log.warn("Invalid request parameters: {}", e.getMessage());
            return ResponseEntity.badRequest().body(buildErrorResponse(e.getMessage()));
        } catch (Exception e) {
            // Server errors - log full exception and return 500 Internal Server Error
            log.error("Error processing mamba report request", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(buildErrorResponse("An internal error occurred while processing the request"));
        }
    }

    /**
     * Build MambaReportCriteria from HTTP request parameters.
     */
    private MambaReportCriteria buildCriteriaFromRequest(HttpServletRequest request, String reportId, Integer pageNumber, Integer pageSize) {
        MambaReportCriteria searchCriteria = new MambaReportCriteria();

        // Set report_id
        if (reportId != null && !reportId.trim().isEmpty()) {
            searchCriteria.setReportId(reportId);
        }

        // Set pagination
        searchCriteria.setPageNumber(pageNumber);
        searchCriteria.setPageSize(pageSize);

        // Process additional parameters as search fields
        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            String paramValue = request.getParameter(paramName);

            // Skip already processed parameters
            if ("report_id".equals(paramName) || "page_number".equals(paramName) || "page_size".equals(paramName)) {
                continue;
            }

            // Add as search field
            searchCriteria.getSearchFields().add(new MambaReportSearchField(paramName, paramValue));
        }

        return searchCriteria;
    }

    /**
     * Build pagination metadata.
     */
    private MambaReportPagination buildPagination(MambaReportCriteria criteria, Integer totalRecords) {
        Integer pageSize = criteria.getPageSize() != null ? criteria.getPageSize() : 50;
        Integer totalPages = (int) Math.ceil((double) totalRecords / pageSize);

        MambaReportPagination pagination = new MambaReportPagination();
        pagination.setPageNumber(criteria.getPageNumber() != null ? criteria.getPageNumber() : 1);
        pagination.setPageSize(pageSize);
        pagination.setTotalRecords(totalRecords);
        pagination.setTotalPages(totalPages);

        return pagination;
    }

    /**
     * Build error response.
     */
    private Map<String, Object> buildErrorResponse(String message) {
        Map<String, Object> response = new HashMap<String, Object>();
        response.put("error", message);
        response.put("results", new ArrayList<MambaReportItem>());
        response.put("pagination", new MambaReportPagination());
        return response;
    }
}
