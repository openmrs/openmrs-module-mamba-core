package org.openmrs.module.mambacore.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

public class StringReplacerUtil {
	
	public static void replaceString(InputStream inputStream, OutputStream outputStream, String target, String replacement)
            throws IOException {

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
             BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(outputStream))) {

            String line;
            while ((line = reader.readLine()) != null) {
                String modifiedLine = line.replace(target, replacement);
                writer.write(modifiedLine);
                writer.newLine();
            }
        }
    }
}
