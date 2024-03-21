/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api.model;

import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;


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
