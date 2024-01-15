/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ohrimambacore.api.dao.impl;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.openmrs.module.ohrimambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.test.BaseModuleContextSensitiveTest;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.List;

import static org.mockito.Mockito.when;

public class JdbcMambaReportItemDaoTest {

    @Mock
    MambaReportItemDao mambaReportItemDao;

    @Mock
    private DataSource dataSource;

    @Mock
    private Connection connection;

    @Mock
    private CallableStatement callableStatementColumnNames;

    @Mock
    private CallableStatement callableStatementGenerateReport;

    @Mock
    private ResultSet resultSetColumnNames;

    @Mock
    private ResultSet resultSetReport;

    @Mock
    private ResultSetMetaData metaData;

    final String reportId = "total_deliveries";

    @Before
    public void setUp() throws Exception {

        MockitoAnnotations.initMocks(this);

        when(dataSource.getConnection()).thenReturn(connection);

        when(connection.prepareCall("{CALL sp_mamba_get_report_column_names(?)}")).thenReturn(callableStatementColumnNames);
        when(connection.prepareCall("{CALL sp_mamba_generate_report_wrapper(?, ?, ?)}")).thenReturn(callableStatementGenerateReport);

        when(callableStatementColumnNames.execute()).thenReturn(true);
        when(callableStatementColumnNames.getResultSet()).thenReturn(resultSetColumnNames);
        when(resultSetColumnNames.next()).thenReturn(true, false);
        when(resultSetColumnNames.getString(1)).thenReturn("total_deliveries");

        when(callableStatementGenerateReport.execute()).thenReturn(true);
        when(callableStatementGenerateReport.getResultSet()).thenReturn(resultSetReport);

        when(resultSetReport.getMetaData()).thenReturn(metaData);
        when(metaData.getColumnCount()).thenReturn(1);
        when(metaData.getColumnName(1)).thenReturn("total_deliveries");

        when(resultSetReport.getString(1)).thenReturn("32");
    }

    @Test
    public void mambaReportItemShouldNotBeNull() {
        Assert.assertNotNull(mambaReportItemDao);
    }

    @Test
    public void getMambaReport_shouldReturnEmptyList() {
        List<MambaReportItem> mambaReportItems = mambaReportItemDao.getMambaReport("total_deliveries");
        Assert.assertNotNull(mambaReportItems);
    }

    @Test
    public void getMambaReport_noReportId_shouldReturnMessageReportIdRequired() {

    }

}
