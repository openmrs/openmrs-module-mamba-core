package org.openmrs.module.mambacore.debezium;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.config.spi.ConfigSource;
import org.slf4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

/**
 * @author smallGod
 * @date: 21/10/2024
 */
@ApplicationScoped
public class DebeziumConfigSource implements ConfigSource {

    private final Map<String, String> properties = new HashMap<>();
    @Inject
    private Logger logger;

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