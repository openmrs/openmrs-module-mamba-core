/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.debezium;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

public class DebeziumConfigSource implements ConfigSource {

    private static final Logger logger = LoggerFactory.getLogger(DebeziumConfigSource.class);

    private final Map<String, String> properties = new HashMap<>();

    public DebeziumConfigSource() {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("META-INF/debezium.properties")) {
            if (input == null) {
                logger.error("Sorry, unable to find debezium.properties");
                return;
            }

            Properties prop = new Properties();
            prop.load(input);

            for (String name : prop.stringPropertyNames()) {
                properties.put(name, prop.getProperty(name));
            }
        } catch (IOException ex) {
            logger.error("Error reading debezium.properties", ex);
            throw new RuntimeException("Error reading debezium.properties", ex);
        }
    }

    @Override
    public Map<String, String> getProperties() {
        return properties;
    }

    @Override
    public String getValue(String propertyName) {
        return properties.get(propertyName);
    }

    @Override
    public Set<String> getPropertyNames() {
        return this.properties.keySet();
    }

    @Override
    public int getOrdinal() {
        return 100;
    }

    @Override
    public String getName() {
        return "DebeziumConfigSource";
    }
}