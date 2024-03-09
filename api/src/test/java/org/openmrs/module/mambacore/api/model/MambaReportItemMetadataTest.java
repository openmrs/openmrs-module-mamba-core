package org.openmrs.module.mambacore.api.model;

/**
 * date: 19/01/2024
 */

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

public class MambaReportItemMetadataTest {

    private MambaReportItemMetadata mambaReportItemMetadata;

    @Before
    public void setup() {
        mambaReportItemMetadata = new MambaReportItemMetadata();
    }

    @Test
    public void testSetAndGetSerialId() {
        Integer serialId = 3;
        mambaReportItemMetadata.setSerialId(serialId);

        assertEquals(serialId, mambaReportItemMetadata.getSerialId());
    }

    @Test
    public void testParameterizedConstructor() {
        Integer serialId = 3;

        MambaReportItemMetadata metadataInstance = new MambaReportItemMetadata(serialId);

        assertEquals(serialId, metadataInstance.getSerialId());
    }

    @Test
    public void testDefaultConstructor() {
        assertNull(mambaReportItemMetadata.getSerialId());
    }
}
