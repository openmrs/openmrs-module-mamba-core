package org.openmrs.module.mambacore.util;

import org.openmrs.api.context.Context;

import java.util.Properties;

public class MambaETLProperties {
	
	private static MambaETLProperties instance;
	
	private final String locale;
	
	private final int columns;
	
	private final int incremental;
	
	private final int automated;
	
	private final int interval;
	
	private final String driver;
	
	private final String url;
	
	private final String userName;
	
	private final String password;
	
	private final int connectionInitialSize = 4;
	
	private final int connectionMaxTotal = 20;
	
	private MambaETLProperties() {
		
		Properties properties = Context.getRuntimeProperties();
		
		this.locale = getProperty(properties, "mambaetl.analysis.locale", "en");
		this.columns = getIntProperty(properties, "mambaetl.analysis.columns", 50);
		this.incremental = getIntProperty(properties, "mambaetl.analysis.incremental_mode", 0);
		this.automated = getIntProperty(properties, "mambaetl.analysis.automated_flattening", 0);
		this.interval = getIntProperty(properties, "mambaetl.analysis.etl_interval", 300);
		
		this.driver = properties.getProperty("mambaetl.analysis.db.driver",
		    properties.getProperty("connection.driver_class"));
		this.url = properties.getProperty("mambaetl.analysis.db.url",
		    "jdbc:mysql://localhost:3306/analysis_db?autoReconnect=true&useSSL=false&allowMultiQueries=true");
		this.userName = properties.getProperty("mambaetl.analysis.db.username",
		    properties.getProperty("connection.username"));
		this.password = properties.getProperty("mambaetl.analysis.db.password",
		    properties.getProperty("connection.password"));
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
	
	public String getDriver() {
		return driver;
	}
	
	public String getUrl() {
		return url;
	}
	
	public String getUserName() {
		return userName;
	}
	
	public String getPassword() {
		return password;
	}
	
	public int getConnectionInitialSize() {
		return connectionInitialSize;
	}
	
	public int getConnectionMaxTotal() {
		return connectionMaxTotal;
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
