package org.openmrs.module.ohrimambacore.task;

import org.openmrs.api.context.Context;
import org.openmrs.module.ohrimambacore.api.FlattenDatabaseService;
import org.openmrs.scheduler.tasks.AbstractTask;

/**
 * @author smallGod
 * date: 26/10/2023
 */
public class FlattenTableTask extends AbstractTask {

    @Override
    public void execute() {

        System.out.println("FlattenTableTask execute() called...");

        if (!isExecuting) {

            System.out.println("FlattenTableTask running...");
            startExecuting();

            try {
                getService().flattenDatabase();
            } catch (Exception e) {
                System.err.println("Error while running FlattenTableTask: " + e.getMessage());
                e.printStackTrace();
            } finally {
                stopExecuting();
                System.out.println("FlattenTableTask completed & stopped...");
            }
        } else {
            System.err.println("Error, Task already running, can't execute again");
        }
    }

    private FlattenDatabaseService getService() {
        return Context.getService(FlattenDatabaseService.class);
    }
}
