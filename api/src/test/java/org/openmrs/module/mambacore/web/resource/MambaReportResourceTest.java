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

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.openmrs.module.mambacore.api.MambaReportService;
import org.openmrs.module.mambacore.api.model.MambaReportPagination;
import org.openmrs.module.mambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.mambacore.api.parameter.MambaReportSearchField;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RequestContext;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class MambaReportResourceTest {

    private static final String LOCATION_UUID = "e44cb0fc-abd3-4b41-ac0d-8e6f0e55a63a";

    private final MambaReportResource resource = new MambaReportResource() {

        @Override
        protected MambaReportService getService() {
            return mambaReportService;
        }
    };

    @Mock
    private MambaReportService mambaReportService;

    @Mock
    private HttpServletRequest request;

    private AutoCloseable mocks;

    @Before
    public void setUp() {
        mocks = MockitoAnnotations.openMocks(this);
    }

    @After
    public void tearDown() throws Exception {
        mocks.close();
    }

    private RequestContext buildRequestContext(Map<String, String> params) {
        when(request.getParameterNames()).thenReturn(new Vector<>(params.keySet()).elements());
        for (Map.Entry<String, String> param : params.entrySet()) {
            when(request.getParameter(param.getKey())).thenReturn(param.getValue());
        }
        // RequestContext is mocked rather than constructed because its constructor
        // initializes RestConstants, which reads a global property through Context
        RequestContext context = mock(RequestContext.class);
        when(context.getRequest()).thenReturn(request);
        return context;
    }

    @Test
    @SuppressWarnings("unchecked")
    public void search_shouldMapRequestParametersToCriteria() throws Exception {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("report_id", "total_deliveries");
        params.put("page_number", "2");
        params.put("page_size", "25");
        params.put("location", LOCATION_UUID);

        when(mambaReportService.getMambaReportByCriteria(any(MambaReportCriteria.class)))
                .thenReturn(new ArrayList<>());
        when(mambaReportService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(100);

        SimpleObject response = resource.search(buildRequestContext(params));

        ArgumentCaptor<MambaReportCriteria> captor = ArgumentCaptor.forClass(MambaReportCriteria.class);
        verify(mambaReportService, times(1)).getMambaReportByCriteria(captor.capture());

        MambaReportCriteria criteria = captor.getValue();

        // report_id, page_number and page_size must be mapped to their criteria
        // properties and never leak into the search fields
        Assert.assertEquals("total_deliveries", criteria.getReportId());
        Assert.assertEquals(Integer.valueOf(2), criteria.getPageNumber());
        Assert.assertEquals(Integer.valueOf(25), criteria.getPageSize());

        List<String> reservedParams = Arrays.asList("report_id", "page_number", "page_size");
        for (MambaReportSearchField field : criteria.getSearchFields()) {
            Assert.assertFalse("reserved parameter became a search field: " + field.getColumn(),
                    reservedParams.contains(field.getColumn()));
        }

        // any other parameter is converted to a search field
        Assert.assertEquals(1, criteria.getSearchFields().size());
        MambaReportSearchField locationField = criteria.getSearchFields().get(0);
        Assert.assertEquals("location", locationField.getColumn());
        Assert.assertEquals(LOCATION_UUID, locationField.getValue());

        // pagination metadata is computed from the parsed parameters
        MambaReportPagination pagination = (MambaReportPagination) response.get("pagination");
        Assert.assertEquals(Integer.valueOf(2), pagination.getPageNumber());
        Assert.assertEquals(Integer.valueOf(25), pagination.getPageSize());
        Assert.assertEquals(Integer.valueOf(100), pagination.getTotalRecords());
        Assert.assertEquals(Integer.valueOf(4), pagination.getTotalPages());

        Assert.assertNotNull(response.get("results"));
    }

    @Test
    @SuppressWarnings("unchecked")
    public void search_shouldReturnEmptyResultsWhenReportIdIsMissing() throws Exception {
        SimpleObject response = resource.search(buildRequestContext(new LinkedHashMap<>()));

        Assert.assertTrue(((List<Object>) response.get("results")).isEmpty());

        verify(mambaReportService, never()).getMambaReportByCriteria(any(MambaReportCriteria.class));
        verify(mambaReportService, never()).getMambaReportSize(any(MambaReportCriteria.class));
    }
}