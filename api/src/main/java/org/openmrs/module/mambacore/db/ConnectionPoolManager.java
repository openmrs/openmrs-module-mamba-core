/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.db;

import org.apache.commons.dbcp2.BasicDataSource;
import org.openmrs.module.mambacore.util.MambaETLProperties;

public class ConnectionPoolManager {
	
	private static ConnectionPoolManager instance = null;
	
	private static final BasicDataSource dataSource = new BasicDataSource();
	
	private ConnectionPoolManager() {
		
		MambaETLProperties props = MambaETLProperties.getInstance();
		
		dataSource.setDriverClassName(props.getOpenmrsDbDriver());
		dataSource.setUsername(props.getMambaETLuser());
		dataSource.setPassword(props.getMambaETLuserPassword());
		dataSource.setUrl(props.getOpenmrsDbConnectionUrl());
		
		dataSource.setInitialSize(props.getConnectionInitialSize());
		dataSource.setMaxTotal(props.getConnectionMaxTotal());
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
