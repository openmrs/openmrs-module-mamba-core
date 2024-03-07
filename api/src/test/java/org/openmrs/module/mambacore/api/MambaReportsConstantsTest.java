package org.openmrs.module.mambacore.api;

/**
 * date: 19/01/2024
 */

import org.junit.Test;

import static org.junit.Assert.*;

public class MambaReportsConstantsTest {

    @Test
    public void testViewMambaReportConstant() {
        assertEquals("View MambaReport", MambaReportsConstants.VIEW_MAMBA_REPORT);
    }

    @Test
    public void testConstantIsNotNull() {
        assertNotNull(MambaReportsConstants.VIEW_MAMBA_REPORT);
    }

    @Test
    public void testConstantIsNotChangedAccidentally() {
        // Ensure that the constant value is not accidentally changed
        assertEquals("View MambaReport", MambaReportsConstants.VIEW_MAMBA_REPORT);
    }
}
