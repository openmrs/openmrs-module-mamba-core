package org.openmrs.module.mambacore.util;

import org.openmrs.api.context.Context;

import java.util.Arrays;
import java.util.List;
import java.util.Properties;

public class MambaETLProperties {

    private static MambaETLProperties instance;

    private final String locale;

    private final int columns;

    private final int incremental;

    private final int automated;

    private final int interval;

    private final String openmrsDbDriver;

    private final String openmrsDbConnectionUrl;

    private final String mambaETLuser;

    private final String mambaETLuserPassword;

    private final String openmrsDatabase;

    private final String etlDatababase;

    private final List<String> tablesWithChangesToStream;

    private final int connectionInitialSize = 4;

    private final int connectionMaxTotal = 20;

    private MambaETLProperties() {

        Properties properties = Context.getRuntimeProperties();

        this.openmrsDbDriver = properties.getProperty("connection.driver_class");
        this.openmrsDbConnectionUrl = properties.getProperty("connection.url");

        this.mambaETLuser = properties.getProperty("mambaetl.analysis.db.username",
                properties.getProperty("connection.username"));
        this.mambaETLuserPassword = properties.getProperty("mambaetl.analysis.db.password",
                properties.getProperty("connection.password"));

        this.openmrsDatabase = getProperty(properties, "mambaetl.analysis.db.openmrs_database", "openmrs");
        this.etlDatababase = getProperty(properties, "mambaetl.analysis.db.etl_database", "analysis_db");

        this.locale = getProperty(properties, "mambaetl.analysis.locale", "en");
        this.columns = getIntProperty(properties, "mambaetl.analysis.columns", 40);
        this.incremental = getIntProperty(properties, "mambaetl.analysis.incremental_mode", 1);
        this.automated = getIntProperty(properties, "mambaetl.analysis.automated_flattening", 0);
        this.interval = getIntProperty(properties, "mambaetl.analysis.etl_interval", 300);
        this.tablesWithChangesToStream = Arrays.asList("obs", "encounter");//TODO include more
    }

    public static synchronized MambaETLProperties getInstance() {
        if (instance == null) {
            instance = new MambaETLProperties();
        }
        return instance;
    }

    public String getLocale() {
        return locale;
    }

    public int getColumns() {
        return columns;
    }

    public int getIncremental() {
        return incremental;
    }

    public int getAutomated() {
        return automated;
    }

    public int getInterval() {
        return interval;
    }

    public String getOpenmrsDbDriver() {
        return openmrsDbDriver;
    }

    public String getOpenmrsDbConnectionUrl() {
        return openmrsDbConnectionUrl;
    }

    public String getMambaETLuser() {
        return mambaETLuser;
    }

    public String getMambaETLuserPassword() {
        return mambaETLuserPassword;
    }

    public String getOpenmrsDatabase() {
        return openmrsDatabase;
    }

    public String getEtlDatababase() {
        return etlDatababase;
    }

    public int getConnectionInitialSize() {
        return connectionInitialSize;
    }

    public int getConnectionMaxTotal() {
        return connectionMaxTotal;
    }

    public List<String> getTablesWithChangesToStream() {
        return tablesWithChangesToStream;
    }

    // Example MambaETLProperties methods
    public String getSourceDatabaseHost() {
        return "localhost"; // TODO: put in properties file
    }

    public String getSourceDatabasePort() {
        return "3306"; // TODO: put in properties file
    }

    public String getSourceDatabaseServerId() {
        return "85744"; // TODO: put in properties file
    }

    public String getHistoryFilePath() {
        return "/Users/smallgod/srv/downloads/dbhistory.dat"; // TODO: put in properties file
    }

    private String getProperty(Properties properties, String key, String defaultValue) {
        String value = properties.getProperty(key);
        return (value == null || value.isEmpty()) ? defaultValue : value.trim();
    }

    private int getIntProperty(Properties properties, String key, int defaultValue) {
        String value = properties.getProperty(key);
        return (value == null || value.isEmpty()) ? defaultValue : Integer.parseInt(value.trim());
    }
}
