package org.openmrs.module.mambacore.api.model;

/**
 * date: 19/01/2024
 */

import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.*;

public class MambaReportItemTest {

    private MambaReportItem mambaReportItem;

    @Before
    public void setup() {
        mambaReportItem = new MambaReportItem();
    }

    @Test
    public void testSetAndGetSerialId() {
        Integer serialId = 5;
        mambaReportItem.setSerialId(serialId);

        assertEquals(serialId, mambaReportItem.getSerialId());
    }

    @Test
    public void testSetAndGetRecord() {
        MambaReportItemColumn column1 = new MambaReportItemColumn("total_deliveries", "1");

        List<MambaReportItemColumn> record = new ArrayList<>();
        record.add(column1);

        mambaReportItem.setRecord(record);

        assertEquals(record, mambaReportItem.getRecord());
    }

    @Test
    public void testDefaultConstructor() {
        assertNotNull(mambaReportItem.getRecord());
        assertTrue(mambaReportItem.getRecord().isEmpty());
    }
}
