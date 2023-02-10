package org.openmrs.ohrimamba;

import org.openmrs.ohrimamba.util.ReadFileFromResources;

import java.io.*;
import java.util.concurrent.*;
import java.util.function.Consumer;

/**
 * @author Arthur M.D
 * @date: 02-07-2023
 */
public class ScriptRunner {

    public void execute() throws IOException, InterruptedException, ExecutionException, TimeoutException {

         String compileScriptDirName = "src/main/resources/_core/database/mysql";

        String homeDir = System.getProperty("user.home");
        String compileScriptFileName = "compile.sh";

        ReadFileFromResources readFile = new ReadFileFromResources();
        //InputStream inputStream = readFile.getFileAsIOStream(compileScriptFileName);

        ProcessBuilder builder = new ProcessBuilder();
        builder.directory(new File(compileScriptDirName));
        builder.command("sh", "./compile.sh");

        Process process = builder.start();
        StreamGobbler streamGobbler = new StreamGobbler(
                process.getInputStream(), System.out::println);
        Future<?> future = Executors.newSingleThreadExecutor().submit(streamGobbler);
        int exitCode = process.waitFor();
        System.out.println("exited: " + exitCode);
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