package org.openmrs.ohrimamba;

import org.openmrs.ohrimamba.util.FileOperationService;

import java.io.*;
import java.nio.file.Path;
import java.util.concurrent.*;
import java.util.function.Consumer;

/**
 * @author Arthur M.D
 * @date: 02-07-2023
 */
public class ScriptRunner {

    private final FileOperationService fileOperations;

    public ScriptRunner() {
        this.fileOperations = new FileOperationService();
    }


    public void compileForMysql() throws IOException, InterruptedException, ExecutionException, TimeoutException {
        String compileScriptFileDirectory = "_core/database/mysql";
        compileForMysql(compileScriptFileDirectory);
    }

    public void compileForPostgres() throws IOException, InterruptedException, ExecutionException, TimeoutException {
        String compileScriptFileDirectory = "";
        compile(compileScriptFileDirectory);
    }

    public void compileForMysql(String compileScriptFileDirectory) throws IOException, InterruptedException, ExecutionException, TimeoutException {

        // String compileScriptDirName = "src/main/resources/_core/database/mysql";
        // String homeDir = System.getProperty("user.home");
        compile(compileScriptFileDirectory);
    }

    private void compile(String compileScriptAbsDirName) throws IOException, InterruptedException, ExecutionException, TimeoutException {

        String absolutePath = fileOperations.getDefaultResourceDirectory().getAbsolutePath()
                + File.separator + compileScriptAbsDirName;

        System.out.println("path: " + absolutePath);

        System.out.println("Res dir: " + this.getClass().getResource("/").getPath());

        File dirPath = fileOperations.getParentDirectoryOrItselfIfDirectory(absolutePath);

        ProcessBuilder builder = new ProcessBuilder();
        builder.directory(dirPath);
        builder.command("sh", "./compile.sh");

        Process process = builder.start();
        StreamGobbler streamGobbler = new StreamGobbler(process.getInputStream(), System.out::println);
        Future<?> future = Executors.newSingleThreadExecutor().submit(streamGobbler);
        int exitCode = process.waitFor();
        future.get(10, TimeUnit.SECONDS);
        //System.out.println("Successful: " + isSuccessful + ", process is alive: " + process.isAlive());
    }

    private static final class StreamGobbler implements Runnable {
        private final InputStream inputStream;
        private final Consumer<String> consumer;

        public StreamGobbler(InputStream inputStream, Consumer<String> consumer) {
            this.inputStream = inputStream;
            this.consumer = consumer;
        }

        @Override
        public void run() {
            new BufferedReader(new InputStreamReader(inputStream)).lines()
                    .forEach(consumer);
        }
    }
}