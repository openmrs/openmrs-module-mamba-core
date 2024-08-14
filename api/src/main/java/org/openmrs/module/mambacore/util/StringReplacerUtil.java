package org.openmrs.module.mambacore.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

public class StringReplacerUtil {

    private static final Logger log = LoggerFactory.getLogger(StringReplacerUtil.class);

    public static Path replaceStrings(InputStream inputStream, Map<String, String> replacements) throws IOException {
        Path tempFile = Files.createTempFile("mamba_jdbc_create_stored_procedures", ".sql");

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8));
             BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(Files.newOutputStream(tempFile.toFile().toPath()), StandardCharsets.UTF_8))) {

            String line;
            while ((line = reader.readLine()) != null) {
                for (Map.Entry<String, String> entry : replacements.entrySet()) {
                    line = line.replace(entry.getKey(), entry.getValue());
                }
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            log.error("Error replacing strings", e);
            throw e;
        }
        return tempFile;
    }
}