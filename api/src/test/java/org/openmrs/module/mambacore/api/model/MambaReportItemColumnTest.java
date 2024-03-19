package org.openmrs.module.mambacore.api.model;

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

public class MambaReportItemColumnTest {

    private MambaReportItemColumn mambaReportItemColumn;

    @Before
    public void setup() {
        mambaReportItemColumn = new MambaReportItemColumn();
    }

    @Test
    public void testSetAndGetColumn() {
        String column = "total_deliveries";
        mambaReportItemColumn.setColumn(column);

        assertEquals(column, mambaReportItemColumn.getColumn());
    }

    @Test
    public void testSetAndGetValue() {
        Object value = "5";
        mambaReportItemColumn.setValue(value);

        assertEquals(value, mambaReportItemColumn.getValue());
    }

    @Test
    public void testParameterizedConstructor() {
        String column = "total_deliveries";
        Object value = "5";

        MambaReportItemColumn columnInstance = new MambaReportItemColumn(column, value);

        assertEquals(column, columnInstance.getColumn());
        assertEquals(value, columnInstance.getValue());
    }

    @Test
    public void testDefaultConstructor() {
        assertNull(mambaReportItemColumn.getColumn());
        assertNull(mambaReportItemColumn.getValue());
    }
}
