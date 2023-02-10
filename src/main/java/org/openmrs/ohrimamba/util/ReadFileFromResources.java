package org.openmrs.ohrimamba.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class ReadFileFromResources {

    public InputStream getFileAsIOStream(final String fileName) {

        InputStream ioStream = this.getClass()
                .getClassLoader()
                .getResourceAsStream(fileName);

        if (ioStream == null) {
            throw new IllegalArgumentException(fileName + " is not found");
        }
        return ioStream;
    }

    /**
     * @param fileName file name from src/resources e.g. _core/database/mysql or _core/database/mysql/text.sql
     * @return
     * @throws IOException
     */
    public File getResourcesFileFromInputStream(String fileName) throws IOException {

        InputStream inputStream = null;

        try {

            // ReadFileFromResources readFile = new ReadFileFromResources();
            // InputStream inputStream = readFile.getFileAsIOStream(compileScriptFileName);
            // inputStream = Files.newInputStream(new File("src/main/resources/sample.txt").toPath());

            ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
            inputStream = classLoader.getResourceAsStream(fileName);

            File targetFile = new File("src/main/resources/targetFile.tmp");

            java.nio.file.Files.copy(
                    inputStream,
                    targetFile.toPath(),
                    StandardCopyOption.REPLACE_EXISTING);


        } finally {

            if (inputStream != null)
                inputStream.close();
        }
        return file;
    }

    public File getFileFolderPath(String fileName){

    }
}
