package org.openmrs.module.mambacore.db;

/**
 * date: 19/01/2024
 */

import org.apache.commons.dbcp2.BasicDataSource;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockitoAnnotations;
import org.openmrs.api.AdministrationService;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

public class ConnectionPoolManagerTest extends BaseModuleContextSensitiveTest {

    @Autowired
    @Qualifier("adminService")
    private AdministrationService administrationService;

    @Before
    public void setUp() throws Exception {
        MockitoAnnotations.initMocks(this);
        executeDataSet("org/openmrs/module/mambacore/include/MambaGlobalproperties.xml");
    }

    @After
    public void tearDown() {
    }

    @Test
    public void testGetInstance() {
        ConnectionPoolManager instance1 = ConnectionPoolManager.getInstance();
        ConnectionPoolManager instance2 = ConnectionPoolManager.getInstance();

        assertNotNull(instance1);
        assertNotNull(instance2);
        assertEquals(instance1, instance2);
    }

    @Test
    public void getMambaGlobalProperty_shouldGetDriver() {

        String propertyValue = administrationService.getGlobalProperty("mambaetl.analysis.db.driver");
        assertEquals("testDriver", propertyValue);
    }

    @Test
    public void getMambaGlobalProperty_shouldGetDbUrl() {

        String propertyValue = administrationService.getGlobalProperty("mambaetl.analysis.db.url");
        assertEquals("testUrl", propertyValue);
    }

    @Test
    public void getMambaGlobalProperty_shouldGetDbUsername() {

        String propertyValue = administrationService.getGlobalProperty("mambaetl.analysis.db.username");
        assertEquals("testUsername", propertyValue);
    }

    @Test
    public void getMambaGlobalProperty_shouldGetDbPassword() {

        String propertyValue = administrationService.getGlobalProperty("mambaetl.analysis.db.password");
        assertEquals("testPassword", propertyValue);
    }

    @Test
    public void testGetDataSource() {

        ConnectionPoolManager connectionPoolManager = ConnectionPoolManager.getInstance();
        BasicDataSource dataSource = connectionPoolManager.getDataSource();

        assertNotNull(dataSource);
        assertEquals(4, dataSource.getInitialSize());
        assertEquals(20, dataSource.getMaxTotal());
    }
}
