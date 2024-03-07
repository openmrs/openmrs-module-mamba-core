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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

public class MambaReportSearchFieldTest {

    @Test
    public void defaultConstructor_shouldInitAllPropertiesToNull() {

        MambaReportSearchField field = new MambaReportSearchField();
        assertNull(field.getColumn());
        assertNull(field.getOperator());
        assertNull(field.getValue());
        assertNull(field.getLogicalOperator());
    }

    @Test
    public void constructorWithColumAndValueFields_shouldInitThem() {

        final String column = "ptracker_id";
        final String value = "10319A180260";

        MambaReportSearchField field = new MambaReportSearchField(column, value);
        assertEquals(column, field.getColumn());
        assertEquals(value, field.getValue());
        assertEquals("=", field.getOperator());
        assertEquals("=", field.getLogicalOperator());
    }

    @Test
    public void testFullConstructor() {

        final String column = "ptracker_id";
        final String value = "10319A180260";
        final String logicalOperator = "=";
        final String operator = "=";

        MambaReportSearchField field = new MambaReportSearchField(column, operator, value, logicalOperator);
        assertEquals(column, field.getColumn());
        assertEquals(operator, field.getOperator());
        assertEquals(value, field.getValue());
        assertEquals(logicalOperator, field.getLogicalOperator());
    }

    @Test
    public void testGettersAndSetters() {

        MambaReportSearchField field = new MambaReportSearchField();

        String column = "ptracker_id";
        field.setColumn(column);
        assertEquals(column, field.getColumn());

        String operator = "=";
        field.setOperator(operator);
        assertEquals(operator, field.getOperator());

        String value = "10319A180260";
        field.setValue(value);
        assertEquals(value, field.getValue());

        String logicalOperator = "=";
        field.setLogicalOperator(logicalOperator);
        assertEquals(logicalOperator, field.getLogicalOperator());
    }
}