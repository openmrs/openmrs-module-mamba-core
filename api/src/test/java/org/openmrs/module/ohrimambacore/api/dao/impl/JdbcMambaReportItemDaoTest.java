package org.openmrs.module.ohrimambacore.api.dao.impl;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.openmrs.api.context.Context;
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

public class JdbcMambaReportItemDaoTest extends BaseModuleContextSensitiveTest {

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
        System.out.println(mambaReportItems);
    }

    @Test
    public void getMambaReport_noReportId_shouldReturnMessageReportIdRequired() {

    }

//    @Test
//    public void testGetMambaReport_SuccessfulExecution() throws SQLException {
//
//        MambaReportCriteria criteria = new MambaReportCriteria("report_id");
//        criteria.getSearchFields().add(new MambaReportSearchField("ptracker_id", "=", "10319A180260", "="));
//
//        JdbcMambaReportItemDao dao = new JdbcMambaReportItemDao();
//        dao.setDataSource(dataSource);
//
//        // Execute the method under test
//        List<MambaReportItem> result = dao.getMambaReport(criteria);
//
//        // Assertions
//        assertEquals(2, result.size());
//
//        // Add more assertions based on expected behavior
//    }
//
//    @Test
//    public void testGetMambaReport_NoResults() throws SQLException {
//        // Prepare test data for a scenario where the report generates no results
//        MambaReportCriteria criteria = new MambaReportCriteria("report_id");
//
//        // Set up the tested DAO
//        JdbcMambaReportItemDao dao = new JdbcMambaReportItemDao();
//        dao.setDataSource(dataSource);
//
//        // Execute the method under test
//        List<MambaReportItem> result = dao.getMambaReport(criteria);
//
//        // Assertions for no results scenario
//        assertEquals(1, result.size());
//        // Add more assertions based on expected behavior in case of no results
//    }
//
//    @Test
//    public void testGetMambaReport_NullCriteria() throws SQLException {
//        // Set up the tested DAO
//        JdbcMambaReportItemDao dao = new JdbcMambaReportItemDao();
//        dao.setDataSource(dataSource);
//
//        // Execute the method under test with null criteria
//        assertThrows(NullPointerException.class, () -> dao.getMambaReport(null));
//    }
//
//    @Test
//    public void testGetMambaReport_InvalidReportID() throws SQLException {
//        // Prepare test data for an invalid report ID
//        MambaReportCriteria criteria = new MambaReportCriteria("invalid_report_id");
//
//        // Set up the tested DAO
//        JdbcMambaReportItemDao dao = new JdbcMambaReportItemDao();
//        dao.setDataSource(dataSource);
//
//        // Execute the method under test with an invalid report ID
//        List<MambaReportItem> result = dao.getMambaReport(criteria);
//
//        // Assertions for handling invalid report ID
//        assertTrue(result.isEmpty());
//        // Add more assertions based on the expected behavior with an invalid report ID
//    }
//
//    @Test
//    public void testGetMambaReport_SpecialCharactersInCriteria() throws SQLException {
//        // Prepare test data with special characters in criteria
//        MambaReportCriteria criteria = new MambaReportCriteria("report_id");
//        criteria.getSearchFields().add(new MambaReportSearchField("special_column", "operator", "value", "logicalOperator"));
//
//        // Set up the tested DAO
//        JdbcMambaReportItemDao dao = new JdbcMambaReportItemDao();
//        dao.setDataSource(dataSource);
//
//        // Execute the method under test with special characters in criteria
//        List<MambaReportItem> result = dao.getMambaReport(criteria);
//
//        // Assertions for handling special characters in criteria
//        assertFalse(result.isEmpty());
//        // Add more assertions based on the expected behavior with special characters in criteria
//    }
//
//    @Test
//    public void testGetMambaReport() throws SQLException {
//        // Mocks
//        DataSource dataSource = mock(DataSource.class);
//        Connection connection = mock(Connection.class);
//        CallableStatement callableStatementColumnNames = mock(CallableStatement.class);
//        CallableStatement callableStatementGenerateReport = mock(CallableStatement.class);
//        ResultSet resultSetColumnNames = mock(ResultSet.class);
//        ResultSetMetaData metaData = mock(ResultSetMetaData.class);
//
//        // Mock behaviors
//        when(dataSource.getConnection()).thenReturn(connection);
//        when(connection.prepareCall(anyString())).thenReturn(callableStatementColumnNames, callableStatementGenerateReport);
//        when(callableStatementColumnNames.execute()).thenReturn(true);
//        when(callableStatementColumnNames.getResultSet()).thenReturn(resultSetColumnNames);
//        when(resultSetColumnNames.next()).thenReturn(true, false);
//        when(resultSetColumnNames.getString(1)).thenReturn("column1", "column2");
//        when(callableStatementGenerateReport.execute()).thenReturn(true, false);
//        when(callableStatementGenerateReport.getUpdateCount()).thenReturn(0);
//        when(callableStatementGenerateReport.getResultSet()).thenReturn(resultSetColumnNames);
//        when(resultSetColumnNames.getMetaData()).thenReturn(metaData);
//        when(metaData.getColumnCount()).thenReturn(2);
//        when(metaData.getColumnName(1)).thenReturn("column1");
//        when(metaData.getColumnName(2)).thenReturn("column2");
//        when(resultSetColumnNames.getObject(anyInt())).thenReturn("value1", "value2", "value3", "value4");
//        when(callableStatementColumnNames.getMoreResults()).thenReturn(false);
//        when(callableStatementGenerateReport.getMoreResults()).thenReturn(true, false);
//
//        JdbcMambaReportItemDao dao = new JdbcMambaReportItemDao();
//        dao.setDataSource(dataSource);
//
//        // Test criteria
//        MambaReportCriteria criteria = new MambaReportCriteria("report_id");
//        criteria.getSearchFields().add(new MambaReportSearchField("column", "operator", "value", "logicalOperator"));
//
//        List<MambaReportItem> result = dao.getMambaReport(criteria);
//
//        // Assertions
//        assertEquals(2, result.size()); // Check the number of items returned
//
//        MambaReportItem firstReportItem = result.get(0);
//        assertEquals(1, firstReportItem.getSerialId()); // Check serialId of the first report item
//        assertEquals(2, firstReportItem.getRecord().size()); // Check number of columns in the first report item
//        assertEquals("column1", firstReportItem.getRecord().get(0).getColumnName()); // Check column name
//        assertEquals("value1", firstReportItem.getRecord().get(0).getColumnValue()); // Check column value
//        // Add similar assertions for the second report item
//    }


}
