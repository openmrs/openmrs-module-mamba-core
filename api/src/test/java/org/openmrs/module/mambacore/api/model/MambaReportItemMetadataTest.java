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
