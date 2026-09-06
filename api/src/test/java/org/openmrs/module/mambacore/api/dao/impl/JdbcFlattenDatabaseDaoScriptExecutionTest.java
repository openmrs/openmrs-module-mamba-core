package org.openmrs.module.mambacore.api.dao.impl;

import org.junit.Test;
import org.mockito.Mockito;

import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Tests for the external ETL script compatibility check and the statement-splitting execution path.
 * Plain JUnit 4; the connection is mocked, so no database is required.
 */
public class JdbcFlattenDatabaseDaoScriptExecutionTest {

    @Test
    public void checkScriptCompatibility_shouldAcceptCompilerOutputScript() {
        String script = "CREATE DATABASE mamba_etl_db;\n"
            + "~-~- \n"
            + "USE mamba_etl_db\n"
            + "~-~- \n"
            + "CREATE TABLE t (id INT)";

        assertNull(JdbcFlattenDatabaseDao.checkScriptCompatibility(script));
    }

    @Test
    public void checkScriptCompatibility_shouldAcceptSinglePlainStatement() {
        assertNull(JdbcFlattenDatabaseDao.checkScriptCompatibility(
            "CREATE TABLE t (id INT PRIMARY KEY, name VARCHAR(50));"));
    }

    @Test
    public void checkScriptCompatibility_shouldAcceptCommentsOnlyScript() {
        assertNull(JdbcFlattenDatabaseDao.checkScriptCompatibility(
            "-- header comment\n/* block\ncomment */\n\n"));
    }

    @Test
    public void checkScriptCompatibility_shouldNotCountSemicolonsInsideLiterals() {
        // semicolons, -- and # inside literals or comments must not look like extra statements
        assertNull(JdbcFlattenDatabaseDao.checkScriptCompatibility(
            "INSERT INTO t VALUES ('a;b', 'c--d', 'e#f');"));

        assertNull(JdbcFlattenDatabaseDao.checkScriptCompatibility(
            "SELECT 'it''s; quoted' -- trailing comment with ; semicolon\n"));

        assertNull(JdbcFlattenDatabaseDao.checkScriptCompatibility(
            "SELECT \"double;quoted\" , `ident;ifier` FROM t;"));
    }

    @Test
    public void checkScriptCompatibility_shouldRejectRawDelimiterScript() {
        // condensed from api/src/main/resources/_core/database/mysql/xf_system/sp_mamba_dim_table_insert.sql
        String script = "DROP PROCEDURE IF EXISTS sp_mamba_dim_table_insert;\n"
            + "\n"
            + "DELIMITER //\n"
            + "\n"
            + "CREATE PROCEDURE sp_mamba_dim_table_insert()\n"
            + "BEGIN\n"
            + " SELECT COLUMN_NAME INTO pkey_column FROM INFORMATION_SCHEMA.COLUMNS"
            + " WHERE TABLE_SCHEMA = 'mamba_source_db';\n"
            + " SET column_list = CONCAT(column_list, 'incremental_record', ', ', ';');\n"
            + "END //\n"
            + "\n"
            + "DELIMITER ;\n";

        String error = JdbcFlattenDatabaseDao.checkScriptCompatibility(script);

        assertNotNull(error);
        assertTrue(error.contains("compile-mysql.sh"));
        assertTrue(error.contains("DELIMITER"));
    }

    @Test
    public void checkScriptCompatibility_shouldRejectMultipleStatementsScript() {
        String error = JdbcFlattenDatabaseDao.checkScriptCompatibility(
            "CREATE TABLE t (id INT);\nINSERT INTO t VALUES ('a;b');");

        assertNotNull(error);
        assertTrue(error.contains("compile-mysql.sh"));
        assertTrue(error.contains("2 ;-terminated statements"));
    }

    @Test
    public void countStatements_shouldHonourQuotesCommentsAndEscapes() {
        assertEquals(2, JdbcFlattenDatabaseDao.countStatements("SELECT 1; SELECT 2;"));
        assertEquals(1, JdbcFlattenDatabaseDao.countStatements("INSERT INTO t VALUES ('a;b')"));
        assertEquals(2, JdbcFlattenDatabaseDao.countStatements(
            "-- lead comment\nSELECT 1;\n# hash comment\nSELECT 2;"));
        assertEquals(1, JdbcFlattenDatabaseDao.countStatements("/* ; ; */ SELECT 1;"));
        assertEquals(1, JdbcFlattenDatabaseDao.countStatements("SELECT 'escaped\\';quote'"));
        assertEquals(1, JdbcFlattenDatabaseDao.countStatements("SELECT 'doubled''quote'"));
        assertEquals(0, JdbcFlattenDatabaseDao.countStatements("   \n  "));
    }

    @Test
    public void executeStatements_shouldExecuteEachSeparatedStatement() throws Exception {
        // the compiled shape of a procedure script: statements separated by '~-~-', empties skipped
        String script = "DROP PROCEDURE IF EXISTS sp_x;\n"
            + "\n"
            + "~-~- \n"
            + "CREATE PROCEDURE sp_x()\n"
            + "BEGIN\n"
            + " SELECT 1;\n"
            + "END;\n"
            + "~-~- \n"
            + "CREATE TABLE t (id INT);";

        Connection connection = Mockito.mock(Connection.class);
        PreparedStatement statement = Mockito.mock(PreparedStatement.class);
        when(connection.nativeSQL(anyString())).thenAnswer(invocation -> (String) invocation.getArguments()[0]);
        when(connection.prepareStatement(anyString())).thenReturn(statement);

        new JdbcFlattenDatabaseDao().executeStatements(connection, script, null);

        verify(connection, times(3)).prepareStatement(anyString());
        verify(statement, times(3)).execute();
    }
}
