package org.openmrs.module.ohrimambacore.db;

import org.apache.commons.dbcp2.BasicDataSource;
import org.openmrs.api.AdministrationService;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * @author smallGod
 * date: 08/11/2023
 */
public class ConnectionPoolManager {

    @Autowired
    private static AdministrationService adminService;

    private static BasicDataSource dataSource = new BasicDataSource();

    static {

        dataSource.setDriverClassName(adminService.getGlobalProperty("mambaetl.analysis.db.driver"));
        dataSource.setUrl(adminService.getGlobalProperty("mambaetl.analysis.db.url"));
        dataSource.setUsername(adminService.getGlobalProperty("mambaetl.analysis.db.username"));
        dataSource.setPassword(adminService.getGlobalProperty("mambaetl.analysis.db.password"));

        dataSource.setInitialSize(4); // Initial number of connections
        dataSource.setMaxTotal(20);   // Maximum number of connections
    }

    public static BasicDataSource getDataSource() {
        return dataSource;
    }
}