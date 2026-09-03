package org.openmrs.module.mambacore.util;

import org.openmrs.api.context.Context;
import org.openmrs.util.OpenmrsUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.file.InvalidPathException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

public class MambaETLProperties {
	
	private static final Logger log = LoggerFactory.getLogger(MambaETLProperties.class);
	
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
		
		// External mode is enabled only when etlDirectory is configured AND the path resolves safely
		this.useExternalEtl = false;
		this.etlDirectoryPath = "";
		
		if (!this.etlDirectory.isEmpty()) {
			String appDataDirectory = null;
			try {
				appDataDirectory = OpenmrsUtil.getApplicationDataDirectory();
			}
			catch (Exception e) {
				log.warn("Unable to determine the OpenMRS application data directory; relative external ETL "
				        + "directories cannot be resolved", e);
			}
			
			String resolvedDirectory = resolveEtlDirectory(this.etlDirectory, appDataDirectory);
			if (resolvedDirectory == null) {
				log.warn("External ETL directory '{}' could not be resolved to a usable directory; external "
				        + "ETL mode is disabled and the bundled ETL script will be used", this.etlDirectory);
			} else {
				this.etlDirectoryPath = resolvedDirectory;
				this.useExternalEtl = true;
			}
		}
	}
	
	/**
	 * Resolves the configured external ETL directory to an absolute path.
	 * <p>
	 * Relative values are resolved below the {@code configuration} directory in
	 * {@code appDataDirectory} and must stay inside that directory: any {@code ..} that escapes it
	 * fails resolution. Absolute values are used directly, canonicalized so that symlinks or
	 * {@code ..} segments cannot disguise their real location. The target directory does not have
	 * to exist yet. This method never logs and never throws: any failure is reported by returning
	 * null.
	 * 
	 * @param configuredDirectory value of {@code mambaetl.analysis.etl_directory}
	 * @param appDataDirectory OpenMRS application data directory (ignored for absolute values)
	 * @return canonical absolute path, or null when the value cannot be resolved safely
	 */
	static String resolveEtlDirectory(String configuredDirectory, String appDataDirectory) {
		if (configuredDirectory == null || configuredDirectory.trim().isEmpty()) {
			return null;
		}

		try {
			Path configuredPath = Paths.get(configuredDirectory);

			if (configuredPath.isAbsolute()) {
				// Absolute directories are used directly (documented behavior), canonicalized for a
				// stable, comparable form
				return new File(configuredDirectory).getCanonicalPath();
			}

			if (appDataDirectory == null || appDataDirectory.trim().isEmpty()) {
				return null;
			}

			File configurationDirectory = new File(new File(appDataDirectory), "configuration");
			Path configurationRoot = Paths.get(configurationDirectory.getCanonicalPath());
			Path candidate = Paths.get(new File(configurationDirectory, configuredDirectory).getCanonicalPath());

			// Path.startsWith compares path components, not string prefixes, so a sibling directory such
			// as ".../configuration-backup" is correctly treated as outside ".../configuration"
			if (!candidate.startsWith(configurationRoot)) {
				return null;
			}

			return candidate.toString();
		}
		catch (IOException | InvalidPathException e) {
			return null;
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
