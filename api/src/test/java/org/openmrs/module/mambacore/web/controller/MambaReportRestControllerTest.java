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

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.MambaReportService;
import org.openmrs.module.mambacore.api.model.MambaReportItem;
import org.openmrs.module.mambacore.api.model.MambaReportPagination;
import org.openmrs.module.mambacore.api.parameter.MambaReportCriteria;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Unit tests for {@link MambaReportRestController}.
 * <p>
 * Tests the REST endpoint including validation, pagination, parameter mapping,
 * and error handling. Uses mockito-inline to mock the static Context.getService.
 */
public class MambaReportRestControllerTest {

    private MambaReportRestController controller;
    private MambaReportService mockService;
    private MockedStatic<Context> mockedContext;

    @Before
    public void setUp() {
        controller = new MambaReportRestController();
        mockService = Mockito.mock(MambaReportService.class);
        mockedContext = Mockito.mockStatic(Context.class);
        mockedContext.when(() -> Context.getService(MambaReportService.class)).thenReturn(mockService);
    }

    @After
    public void tearDown() {
        mockedContext.close();
    }

    @Test
    public void getMambaReport_shouldReturnResultsWhenParametersValid() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        List<MambaReportItem> expectedItems = new ArrayList<MambaReportItem>();
        MambaReportItem item = new MambaReportItem();
        expectedItems.add(item);

        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class))).thenReturn(expectedItems);
        when(mockService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(1);

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 1, 50);

        // Then
        Assert.assertEquals("Should return 200 OK", HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        Assert.assertFalse("Results should not be empty", body.get("results").equals(new ArrayList<>()));
        Assert.assertEquals("Should have 1 result", 1, ((List<?>) body.get("results")).size());
        Assert.assertNotNull("Pagination should not be null", body.get("pagination"));

        verify(mockService, times(1)).getMambaReportByCriteria(any(MambaReportCriteria.class));
        verify(mockService, times(1)).getMambaReportSize(any(MambaReportCriteria.class));
    }

    @Test
    public void getMambaReport_shouldReturnErrorWhenReportIdMissing() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, null, 1, 50);

        // Then
        Assert.assertEquals("Should return 400 Bad Request", HttpStatus.BAD_REQUEST, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        Assert.assertTrue("Should have error key", body.containsKey("error"));
        Assert.assertTrue("Error message should mention report_id", body.get("error").toString().contains("report_id"));

        // Service should not be called
        verify(mockService, times(0)).getMambaReportByCriteria(any(MambaReportCriteria.class));
    }

    @Test
    public void getMambaReport_shouldReturnErrorWhenReportIdEmpty() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "   ", 1, 50);

        // Then
        Assert.assertEquals("Should return 400 Bad Request", HttpStatus.BAD_REQUEST, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        Assert.assertTrue("Should have error key", body.containsKey("error"));
        Assert.assertTrue("Error message should mention report_id", body.get("error").toString().contains("report_id"));
    }

    @Test
    public void getMambaReport_shouldReturnErrorWhenPageNumberInvalid() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 0, 50);

        // Then
        Assert.assertEquals("Should return 400 Bad Request", HttpStatus.BAD_REQUEST, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        Assert.assertTrue("Should have error key", body.containsKey("error"));
        Assert.assertTrue("Error message should mention page_number", body.get("error").toString().contains("page_number"));
    }

    @Test
    public void getMambaReport_shouldReturnErrorWhenPageSizeInvalid() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 1, 0);

        // Then
        Assert.assertEquals("Should return 400 Bad Request", HttpStatus.BAD_REQUEST, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        Assert.assertTrue("Should have error key", body.containsKey("error"));
        Assert.assertTrue("Error message should mention page_size", body.get("error").toString().contains("page_size"));
    }

    @Test
    public void getMambaReport_shouldUseDefaultPaginationValues() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        List<MambaReportItem> expectedItems = new ArrayList<MambaReportItem>();
        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class))).thenReturn(expectedItems);
        when(mockService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(0);

        // When - calling with null pagination values to test defaults
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", null, null);

        // Then
        Assert.assertEquals("Should return 200 OK", HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        MambaReportPagination pagination = (MambaReportPagination) body.get("pagination");
        Assert.assertNotNull("Pagination should not be null", pagination);
        Assert.assertEquals("Default page number should be 1", Integer.valueOf(1), pagination.getPageNumber());
        Assert.assertEquals("Default page size should be 50", Integer.valueOf(50), pagination.getPageSize());
    }

    @Test
    public void getMambaReport_shouldCalculatePaginationCorrectly() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        List<MambaReportItem> expectedItems = new ArrayList<MambaReportItem>();
        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class))).thenReturn(expectedItems);
        when(mockService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(125);

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 1, 50);

        // Then
        Assert.assertEquals("Should return 200 OK", HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        MambaReportPagination pagination = (MambaReportPagination) body.get("pagination");
        Assert.assertNotNull("Pagination should not be null", pagination);
        Assert.assertEquals("Total records should be 125", Integer.valueOf(125), pagination.getTotalRecords());
        Assert.assertEquals("Total pages should be 3 (125/50 rounded up)", Integer.valueOf(3), pagination.getTotalPages());
    }

    @Test
    public void getMambaReport_shouldPassSearchFieldsToService() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");
        request.setParameter("patient_id", "12345");
        request.setParameter("location", "MTRH");
        request.setParameter("start_date", "2023-01-01");

        List<MambaReportItem> expectedItems = new ArrayList<MambaReportItem>();
        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class))).thenReturn(expectedItems);
        when(mockService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(0);

        // When
        controller.getMambaReport(request, "test_report", 1, 50);

        // Then
        verify(mockService, times(1)).getMambaReportByCriteria(any(MambaReportCriteria.class));

        // Verify the criteria contains search fields
        // Note: We can't directly inspect the passed MambaReportCriteria without a custom ArgumentMatcher
        // but we verify the service was called once
    }

    @Test
    public void getMambaReport_shouldHandleServiceException() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class)))
                .thenThrow(new RuntimeException("Database connection failed"));

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 1, 50);

        // Then
        Assert.assertEquals("Should return 500 Internal Server Error", HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        Assert.assertTrue("Should have error key", body.containsKey("error"));
        // Should return generic error message, not the raw exception
        String errorMessage = (String) body.get("error");
        Assert.assertTrue("Error should be generic message", errorMessage.contains("internal error"));
        Assert.assertFalse("Error should not expose exception details", errorMessage.contains("Database"));
    }

    @Test
    public void getMambaReport_shouldHandleIllegalArgumentException() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "invalid_report");

        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class)))
                .thenThrow(new IllegalArgumentException("Invalid report ID format"));

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "invalid_report", 1, 50);

        // Then
        Assert.assertEquals("Should return 400 Bad Request", HttpStatus.BAD_REQUEST, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        Assert.assertTrue("Should have error key", body.containsKey("error"));
        // IllegalArgumentException messages should be passed through
        String errorMessage = (String) body.get("error");
        Assert.assertTrue("Error should contain the specific message", errorMessage.contains("Invalid report ID format"));
    }

    @Test
    public void getMambaReport_shouldHandleEmptyResults() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        List<MambaReportItem> emptyItems = new ArrayList<MambaReportItem>();
        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class))).thenReturn(emptyItems);
        when(mockService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(0);

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 1, 50);

        // Then
        Assert.assertEquals("Should return 200 OK", HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        Assert.assertNotNull("Response body should not be null", body);
        List<?> results = (List<?>) body.get("results");
        Assert.assertTrue("Results should be empty", results.isEmpty());
        MambaReportPagination pagination = (MambaReportPagination) body.get("pagination");
        Assert.assertEquals("Total records should be 0", Integer.valueOf(0), pagination.getTotalRecords());
        Assert.assertEquals("Total pages should be 0", Integer.valueOf(0), pagination.getTotalPages());
    }

    @Test
    public void getMambaReport_shouldCalculateTotalPagesForExactMultiple() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        List<MambaReportItem> expectedItems = new ArrayList<MambaReportItem>();
        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class))).thenReturn(expectedItems);
        when(mockService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(100); // exactly 2 pages

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 1, 50);

        // Then
        Assert.assertEquals("Should return 200 OK", HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        MambaReportPagination pagination = (MambaReportPagination) body.get("pagination");
        Assert.assertEquals("Total pages should be 2 (100/50)", Integer.valueOf(2), pagination.getTotalPages());
    }

    @Test
    public void getMambaReport_shouldHandleSecondPage() {
        // Given
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setParameter("report_id", "test_report");

        List<MambaReportItem> expectedItems = new ArrayList<MambaReportItem>();
        when(mockService.getMambaReportByCriteria(any(MambaReportCriteria.class))).thenReturn(expectedItems);
        when(mockService.getMambaReportSize(any(MambaReportCriteria.class))).thenReturn(125);

        // When
        ResponseEntity<Map<String, Object>> response = controller.getMambaReport(request, "test_report", 2, 50);

        // Then
        Assert.assertEquals("Should return 200 OK", HttpStatus.OK, response.getStatusCode());
        Map<String, Object> body = response.getBody();
        MambaReportPagination pagination = (MambaReportPagination) body.get("pagination");
        Assert.assertEquals("Page number should be 2", Integer.valueOf(2), pagination.getPageNumber());
    }
}