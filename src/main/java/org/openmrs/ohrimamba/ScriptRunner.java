package org.openmrs.ohrimamba;

import java.io.File;
import java.io.IOException;
import java.util.concurrent.*;

/**
 * @author Arthur M.D
 */
public class ScriptRunner {

    public void execute() throws IOException, InterruptedException, ExecutionException, TimeoutException {

        ProcessBuilder builder = new ProcessBuilder();

        builder.command("/bin/bash", "./Users/ayinza/srv/applications/mets/ohri-mamba-plugin/src/main/resources/_core/database/mysql/compile.sh");
        builder.directory(new File(System.getProperty("user.home")));
        Process process = builder.start();
        StreamGobbler streamGobbler =
                new StreamGobbler(process.getInputStream(), System.out::println);
        Future<?> future = Executors.newSingleThreadExecutor().submit(streamGobbler);
        int exitCode = process.waitFor();
        assert exitCode == 0;
        future.get(10, TimeUnit.SECONDS);
    }
}
