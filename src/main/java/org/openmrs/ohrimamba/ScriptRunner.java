package org.openmrs.ohrimamba;

import java.io.*;
import java.util.concurrent.*;
import java.util.function.Consumer;

/**
 * @author Arthur M.D
 * @date: 02-07-2023
 */
public class ScriptRunner {

    public void compileForMysql() throws IOException, InterruptedException, ExecutionException, TimeoutException {
        String compileScriptFileDirectory = "";
        compileForMysql(compileScriptFileDirectory);
    }

    public void compileForPostgress() throws IOException, InterruptedException, ExecutionException, TimeoutException {
        String compileScriptFileDirectory = "";
        compile(compileScriptFileDirectory);
    }

    public void compileForMysql(String compileScriptDirName) throws IOException, InterruptedException, ExecutionException, TimeoutException {

        // String compileScriptDirName = "src/main/resources/_core/database/mysql";
        //String homeDir = System.getProperty("user.home");
        String compileScriptFileDirectory = "";
        compile(compileScriptFileDirectory);
    }

    private void compile(String compileScriptDirName) throws IOException, InterruptedException, ExecutionException, TimeoutException {

        ProcessBuilder builder = new ProcessBuilder();
        builder.directory(new File(compileScriptDirName));
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