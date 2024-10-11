/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.db.debezium;

import io.debezium.config.Configuration;
import org.openmrs.module.mambacore.util.MambaETLProperties;

import java.util.stream.Collectors;

/**
 * Provides configuration for Debezium connector
 */
public class DebeziumConfigProvider {
	
	private static final String MYSQL_CONNECTOR_CLASS = "io.debezium.connector.mysql.MySqlConnector";
	
	private static final String CONNECTOR_NAME = "mamba-core-connector";
	
	private static final String SERVER_NAME = "openmrsDbServer";
	
	private static volatile DebeziumConfigProvider instance = null;
	
	private static Configuration config;
	
	private final MambaETLProperties props = MambaETLProperties.getInstance();
	
	private DebeziumConfigProvider() {
		initializeConfig();
	}
	
	public static DebeziumConfigProvider getInstance() {
		if (instance == null) {
			synchronized (DebeziumConfigProvider.class) {
				if (instance == null) {
					instance = new DebeziumConfigProvider();
				}
			}
		}
		return instance;
	}
	
	private void initializeConfig() {
		String source = props.getOpenmrsDatabase();
		
		config = Configuration.create().with("name", CONNECTOR_NAME).with("connector.class", MYSQL_CONNECTOR_CLASS)
		        .with("database.server.id", props.getSourceDatabaseServerId()).with("database.server.name", SERVER_NAME)
		        .with("database.hostname", props.getSourceDatabaseHost())
		        .with("database.port", props.getSourceDatabasePort()).with("database.user", props.getMambaETLuser())
		        .with("database.password", props.getMambaETLuserPassword()).with("database.include.list", source)
		        //.with("table.include.list", getTableIncludeList(source))
		        .with("database.history.file.filename", props.getHistoryFilePath()).build();
	}
	
	private String getTableIncludeList(String source) {
        return props.getTablesWithChangesToStream().stream()
                .map(table -> source + "." + table)
                .collect(Collectors.joining(","));
    }
	
	public Configuration build() {
		return config;
	}
}
