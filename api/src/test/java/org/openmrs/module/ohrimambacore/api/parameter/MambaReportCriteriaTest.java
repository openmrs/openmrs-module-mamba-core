package org.openmrs.module.ohrimambacore.api.parameter;

import org.junit.Test;
import org.junit.Assert;
import org.junit.Before;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;

import static org.junit.Assert.*;

public class MambaReportCriteriaTest {

    final String reportId = "total_active_ds_cases";
    final MambaReportSearchField searchField = new MambaReportSearchField("ptracker_id", "=", "10319A180260", "=");


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

        // Test search fields
        criteria.getSearchFields().add(searchField);
        assertFalse(criteria.getSearchFields().isEmpty());
        assertEquals(1, criteria.getSearchFields().size());
        assertEquals(searchField, criteria.getSearchFields().get(0));
    }
}