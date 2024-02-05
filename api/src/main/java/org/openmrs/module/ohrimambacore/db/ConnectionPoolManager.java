package org.openmrs.module.ohrimambacore.db;

import org.apache.commons.dbcp2.BasicDataSource;
import org.openmrs.api.context.Context;

public class ConnectionPoolManager {
	
	private static ConnectionPoolManager instance = null;
	
	private static final BasicDataSource dataSource = new BasicDataSource();
	
	private ConnectionPoolManager() {
		dataSource.setDriverClassName(Context.getAdministrationService().getGlobalProperty("mambaetl.analysis.db.driver"));
		dataSource.setUrl(Context.getAdministrationService().getGlobalProperty("mambaetl.analysis.db.url"));
		dataSource.setUsername(Context.getAdministrationService().getGlobalProperty("mambaetl.analysis.db.username"));
		dataSource.setPassword(Context.getAdministrationService().getGlobalProperty("mambaetl.analysis.db.password"));
		dataSource.setInitialSize(4); // Initial number of connections
		dataSource.setMaxTotal(20); // Maximum number of connections
	}
	
	public static ConnectionPoolManager getInstance() {
		if (instance == null) {
			instance = new ConnectionPoolManager();
		}
		return instance;
	}
	
	public BasicDataSource getDataSource() {
		return dataSource;
	}
}
