package org.openmrs.module.mambacore.util;

import org.openmrs.api.context.Context;
import org.openmrs.util.OpenmrsUtil;

import java.io.File;
import java.io.IOException;
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
	
	private final int connectionInitialSize = 4;
	
	private final int connectionMaxTotal = 20;
	
	// External ETL configuration properties
	private final String etlDirectory;
	
	private boolean useExternalEtl;
	
	private String etlDirectoryPath;
	
	private final int etlDiscoveryDepth;
	
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
		
		// External ETL configuration
		this.etlDiscoveryDepth = getIntProperty(properties, "mambaetl.analysis.etl_discovery_depth", 5);
		this.etlDirectory = getProperty(properties, "mambaetl.analysis.etl_directory", "");
		
		// Determine if we should use external ETL directory
		// External mode is enabled when etlDirectory is configured
		this.useExternalEtl = !this.etlDirectory.isEmpty();
		
		// Resolve directory path (supports relative to appdata or absolute)
		if (this.useExternalEtl) {
			File dir = new File(this.etlDirectory);
			if (!dir.isAbsolute()) {
				// Relative to application data directory + configuration/
				try {
					File appDataDir = new File(OpenmrsUtil.getApplicationDataDirectory());
					File configDir = new File(appDataDir, "configuration");
					this.etlDirectoryPath = new File(configDir, this.etlDirectory).getAbsolutePath();
				}
				catch (Exception e) {
					// If application data directory cannot be determined, disable external mode
					this.useExternalEtl = false;
					this.etlDirectoryPath = "";
				}
			} else {
				// Sanitize path to prevent traversal outside intended directory
				try {
					this.etlDirectoryPath = dir.getCanonicalPath();
				}
				catch (IOException e) {
					// If path cannot be canonicalized, disable external mode
					this.useExternalEtl = false;
					this.etlDirectoryPath = "";
				}
			}
		} else {
			this.etlDirectoryPath = "";
		}
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
	
	public String getEtlDirectory() {
		return etlDirectory;
	}
	
	public boolean isUseExternalEtl() {
		return useExternalEtl;
	}
	
	public String getEtlDirectoryPath() {
		return etlDirectoryPath;
	}
	
	public int getEtlDiscoveryDepth() {
		return etlDiscoveryDepth;
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
