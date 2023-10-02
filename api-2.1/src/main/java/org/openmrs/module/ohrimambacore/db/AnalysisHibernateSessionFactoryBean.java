package org.openmrs.module.ohrimambacore.db;

import org.openmrs.annotation.OpenmrsProfile;
import org.openmrs.api.db.AdministrationDAO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.orm.hibernate4.LocalSessionFactoryBean;

import java.io.IOException;
import java.util.Properties;

/**
 * @author Arthur D. Mugume, Amos Laboso
 * date: 28/09/2023
 */
@OpenmrsProfile(openmrsPlatformVersion = "2.1.* - 2.3.*")
public class AnalysisHibernateSessionFactoryBean extends LocalSessionFactoryBean {

    @Autowired
    AdministrationDAO administrationDAO;

    @Override
    public void afterPropertiesSet() throws IOException {

        Properties config = getHibernateProperties();

        String dbUrl = administrationDAO.getGlobalProperty("mambaetl.analysis.db.url");
        String dbUsername = administrationDAO.getGlobalProperty("mambaetl.analysis.db.username");
        String dbPassword = administrationDAO.getGlobalProperty("mambaetl.analysis.db.password");
        String dbDriverClass = administrationDAO.getGlobalProperty("mambaetl.analysis.db.driver");

        System.out.println("dbUrl  2.1   : " + dbUrl);
        System.out.println("dbUsername   : " + dbUsername);
        System.out.println("dbPassword   : " + dbPassword);
        System.out.println("dbDriverClass: " + dbDriverClass);

//        config.setProperty("hibernate.connection.url", dbUrl);
//        config.setProperty("hibernate.connection.username", dbUsername);
//        config.setProperty("hibernate.connection.password", dbPassword);
//        config.setProperty("hibernate.connection.driver_class", dbDriverClass);

        config.setProperty("hibernate.connection.url", "jdbc:mysql://localhost:3306/analysis_db?autoReconnect=true");
        config.setProperty("hibernate.connection.username", "openmrs_rwanda_emr");
        config.setProperty("hibernate.connection.password", "password");
        config.setProperty("hibernate.connection.driver_class", "com.mysql.cj.jdbc.Driver");

        super.afterPropertiesSet();
    }
}
