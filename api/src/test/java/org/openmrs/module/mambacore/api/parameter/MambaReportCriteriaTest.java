/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api.parameter;

import org.junit.Test;
import org.junit.Before;

import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;

public class MambaReportCriteriaTest {

    final String reportId = "total_active_ds_cases";
    private MambaReportSearchField searchField;


    @Before
    public void setUp() {
        searchField = new MambaReportSearchField("ptracker_id", "=", "10319A180260", "=");
    }

    @Test
    public void defaultConstructor_shouldInitReportIdToNullAndSearchFieldsToEmptyList() {
        MambaReportCriteria criteria = new MambaReportCriteria();
        assertNull(criteria.getReportId());
        assertNotNull(criteria.getSearchFields());
        assertTrue(criteria.getSearchFields().isEmpty());
    }

    @Test
    public void constructorWithReportId_shouldInitReportIdWithValueAndSearchFieldsToEmptyList() {

        MambaReportCriteria criteria = new MambaReportCriteria(reportId);
        assertEquals(reportId, criteria.getReportId());
        assertNotNull(criteria.getSearchFields());
        assertTrue(criteria.getSearchFields().isEmpty());
    }

    @Test
    public void testGettersAndSetters() {
        MambaReportCriteria criteria = new MambaReportCriteria();
        criteria.setReportId(reportId);
        assertEquals(reportId, criteria.getReportId());

        criteria.getSearchFields().add(searchField);
        assertFalse(criteria.getSearchFields().isEmpty());
        assertEquals(1, criteria.getSearchFields().size());
        assertEquals(searchField, criteria.getSearchFields().get(0));
    }

    @Test
    public void testGetAndSetSearchFields() {
        List<MambaReportSearchField> searchFields = Arrays.asList(
                new MambaReportSearchField("field1", "value1"),
                new MambaReportSearchField("field2", "value2")
        );

        MambaReportCriteria criteria = new MambaReportCriteria();
        criteria.setSearchFields(searchFields);

        assertNotNull(criteria.getSearchFields());
        assertEquals(searchFields, criteria.getSearchFields());
    }
}