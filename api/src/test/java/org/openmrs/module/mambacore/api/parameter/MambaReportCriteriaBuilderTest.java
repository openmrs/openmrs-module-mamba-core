package org.openmrs.module.mambacore.api.parameter;

/**
 * date: 19/01/2024
 */

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

public class MambaReportCriteriaBuilderTest {

    @Test
    public void testBuilderWithReportId() {
        String reportId = "123";
        MambaReportCriteriaBuilder builder = new MambaReportCriteriaBuilder(reportId);

        MambaReportCriteria criteria = builder.build();

        assertNotNull(criteria);
        assertEquals(reportId, criteria.getReportId());
        assertNotNull(criteria.getSearchFields());
        assertEquals(0, criteria.getSearchFields().size());
    }

    @Test
    public void testSetReportId() {
        String reportId = "456";
        MambaReportCriteriaBuilder builder = new MambaReportCriteriaBuilder("123");

        builder.setReportId(reportId);

        MambaReportCriteria criteria = builder.build();

        assertNotNull(criteria);
        assertEquals(reportId, criteria.getReportId());
        assertNotNull(criteria.getSearchFields());
        assertEquals(0, criteria.getSearchFields().size());
    }

    @Test
    public void testAddSearchField() {
        MambaReportSearchField searchField = new MambaReportSearchField("field1", "value1");
        MambaReportCriteriaBuilder builder = new MambaReportCriteriaBuilder("123");

        builder.addSearchField(searchField);

        MambaReportCriteria criteria = builder.build();

        assertNotNull(criteria);
        assertEquals("123", criteria.getReportId());
        assertNotNull(criteria.getSearchFields());
        assertEquals(1, criteria.getSearchFields().size());
        assertEquals(searchField, criteria.getSearchFields().get(0));
    }

    @Test
    public void testBuild() {
        MambaReportCriteriaBuilder builder = new MambaReportCriteriaBuilder("123");

        MambaReportCriteria criteria = builder.build();

        assertNotNull(criteria);
        assertEquals("123", criteria.getReportId());
        assertNotNull(criteria.getSearchFields());
        assertEquals(0, criteria.getSearchFields().size());
    }
}
