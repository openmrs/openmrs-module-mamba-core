package org.openmrs.module.mambacore.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;

public class ResourcePathUtil {

    public static Path getResourcePath2(String resourceName) throws IOException, URISyntaxException {
        ClassLoader classLoader = ResourcePathUtil.class.getClassLoader();
        URL resourceUrl = classLoader.getResource(resourceName);
        if (resourceUrl == null) {
            throw new IOException("Resource not found: " + resourceName);
        }
        return Paths.get(resourceUrl.toURI());
    }

    public static String getResourcePath(String resourceName) {
        return Objects.requireNonNull(ResourcePathUtil.class.getClassLoader().getResource(resourceName)).getPath();
    }

    public static String getResourcePath(String resource, Class<?> clazz) {
        return Objects.requireNonNull(clazz.getClassLoader().getResource(resource)).getPath();
    }

    public static InputStream readResource(String resourcePath) throws IOException {

        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
        try (InputStream inputStream = classLoader.getResourceAsStream(resourcePath)) {
            if (inputStream == null) {
                throw new IOException("Resource not found: " + resourcePath);
            }
            return inputStream;
        }
    }
}