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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

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
