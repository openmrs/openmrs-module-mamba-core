package org.openmrs.ohrimamba;

import java.io.*;
import java.util.concurrent.*;
import java.util.function.Consumer;

/**
 * @author Arthur M.D
 */
public class ScriptRunner {

    public void execute() throws IOException, InterruptedException, ExecutionException, TimeoutException {

        ProcessBuilder builder = new ProcessBuilder();
        String homeDir = System.getProperty("user.home");

        builder.directory(new File("src/main/resources/_core/database/mysql"));
        builder.command("sh", "./compile.sh");
        //builder.command("sh", "-c", "ls");
        Process process = builder.start();
        StreamGobbler streamGobbler = new StreamGobbler(
                process.getInputStream(), System.out::println);
        Future<?> future = Executors.newSingleThreadExecutor().submit(streamGobbler);
        int exitCode = process.waitFor();
        assert exitCode == 0;
        System.out.println("exited: " + exitCode);
        future.get(10, TimeUnit.SECONDS);
        //System.out.println("Successful: " + isSuccessful + ", process is alive: " + process.isAlive());
    }

    private static class StreamGobbler implements Runnable {
        private InputStream inputStream;
        private Consumer<String> consumer;

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
