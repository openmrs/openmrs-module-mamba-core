package org.openmrs.module.ohrimambacore.db;

import org.openmrs.annotation.OpenmrsProfile;
import org.openmrs.api.AdministrationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate5.LocalSessionFactoryBean;

import java.io.IOException;
import java.util.Properties;

/**
 * @author Arthur D. Mugume, Amos Laboso
 * date: 28/09/2023
 */
@OpenmrsProfile(openmrsPlatformVersion = "2.4.* - 9.*")
public class AnalysisHibernateSessionFactoryBean extends LocalSessionFactoryBean {

    @Autowired
    AdministrationService adminService;

    @Override
    public void afterPropertiesSet() throws IOException {

        Properties config = getHibernateProperties();

        String dbUrl = adminService.getGlobalProperty("mambaetl.analysis.db.url");
        String dbUsername = adminService.getGlobalProperty("mambaetl.analysis.db.username");
        String dbPassword = adminService.getGlobalProperty("mambaetl.analysis.db.password");
        String dbDriverClass = adminService.getGlobalProperty("mambaetl.analysis.db.driver");

        config.setProperty("hibernate.connection.url", dbUrl);
        config.setProperty("hibernate.connection.username", dbUsername);
        config.setProperty("hibernate.connection.password", dbPassword);
        config.setProperty("hibernate.connection.driver_class", dbDriverClass);

        super.afterPropertiesSet();
    }
}
