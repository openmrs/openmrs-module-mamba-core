package org.openmrs.ohrimamba.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;

import static java.nio.file.StandardOpenOption.*;

/**
 * @author smallGod
 * date: 28/07/2022
 */
public final class FileOperationService {

    public FileOperationService() {
    }

    /**
     * Create a File if it doesn't exist and return it.
     *
     * @param fileDirectoryPath File to the directory
     * @param fileName          relative file name (last part of the path)
     * @return Created or Existing File
     * @throws IOException IO Exception if any
     */
    public Path createFile(String fileDirectoryPath, String fileName) throws IOException {

        synchronized (this) {

            if (fileDirectoryPath == null || fileDirectoryPath.trim().isEmpty()
                    || fileName == null || fileName.trim().isEmpty()) {
                throw new IOException("Error, File Name or Directory is missing or empty");
            }
            String filePath = fileDirectoryPath.trim() + File.separator + fileName.trim();
            return createFileHelper(filePath);
        }
    }

    /**
     * Create a File Path if it doesn't exist and return it.
     *
     * @param fullFilePath absolute file name
     * @return Created or Existing File Path
     * @throws IOException IO Exception if any
     */
    public Path createFile(String fullFilePath) throws IOException {

        synchronized (this) {

            if (fullFilePath == null || fullFilePath.trim().isEmpty()) {
                throw new IOException("Error, File Name is missing or empty");
            }
            return createFileHelper(fullFilePath);
        }
    }

    /**
     * Create a directory path and all missing directories
     *
     * @param directoryPath a string representation of the directory path
     * @return directory path object
     * @throws IOException IO Exception if any
     */
    public Path createDirectory(String directoryPath) throws IOException {

        synchronized (this) {

            Path dirPath = Paths.get(directoryPath);
            if (!dirPath.toFile().exists()) {
                return Files.createDirectories(dirPath);
            }
            return dirPath;
        }
    }

    /**
     * @param bytes        file bytes to save
     * @param fullFilePath Full path to file including file name and directory
     * @param isOverwrite  True if existing file should be overwritten
     * @return Path to the saved file
     * @throws IOException IO Exception if any
     */
    public Path saveFileToDisk(byte[] bytes, String fullFilePath, boolean isOverwrite) throws IOException {

        synchronized (this) {
            if (fullFilePath == null || fullFilePath.trim().isEmpty()) {
                throw new IOException("Error, File Name is missing or empty");
            }
            Path file = createFile(fullFilePath);

            StandardOpenOption[] writeOptions;
            if (isOverwrite) {
                writeOptions = new StandardOpenOption[]{CREATE, TRUNCATE_EXISTING, WRITE};
            } else {
                writeOptions = new StandardOpenOption[]{CREATE_NEW, WRITE};
            }
            return Files.write(file, bytes, writeOptions);
        }
    }

    public Path getFileDirectoryPath(File file) throws IOException {
        if (file.exists()) return file.toPath();
        else throw new IOException("File does not exist");
    }

    public File getParentDirectoryOrItselfIfDirectory(String absoluteFilePath)
            throws IOException {

        System.out.println("path: " + absoluteFilePath);

        File filePath = new File(absoluteFilePath);
        if (filePath.exists()) {
            if (filePath.isDirectory()) {
                return filePath;
            } else if (filePath.isFile()) {
                return filePath.getParentFile();
            }
        }
        throw new IOException("Invalid file or File does not exist");
    }

    public File getDefaultResourceDirectory() {
        return new File("src" + File.separator
                + "main" + File.separator
                + "resources" + File.separator);
    }

    private Path createFileHelper(String filePath) throws IOException {

        File file = new File(filePath.trim());
        File dir = file.getParentFile();

        if (!dir.exists()) {
            createDirectory(dir.toString());
        }

        if (file.exists()) return file.toPath();
        else return Files.createFile(file.toPath());
    }
}
