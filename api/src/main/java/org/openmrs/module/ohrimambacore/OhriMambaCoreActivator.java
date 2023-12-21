/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.ohrimambacore;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.BaseModuleActivator;
import org.openmrs.module.ohrimambacore.task.FlattenTableTask;
import org.openmrs.scheduler.SchedulerException;
import org.openmrs.scheduler.Task;
import org.openmrs.scheduler.TaskDefinition;

import java.util.Calendar;
import java.util.UUID;

/**
 * This class contains the logic that is run every time this module is either started or shutdown
 */
public class OhriMambaCoreActivator extends BaseModuleActivator {

    private Log log = LogFactory.getLog(getClass());

    public OhriMambaCoreActivator() {
        super();
    }

    /**
     * @see #started()
     */
    public void started() {
        log.info("Started MambaETL base Module");
        registerTask("Mamba-ETL Task", "MambaETL Task - To Flatten and Prepare Reporting Data.", FlattenTableTask.class,
                60 * 60 * 12L, true);
    }

    /**
     * @see #shutdown()
     */

    public void shutdown() {
        log.info("Shutdown MambaETL base Module");
    }

    @Override
    public void stopped() {
        log.info("MambaETL base Module stopped");
        super.stopped();
    }

    @Override
    public void willRefreshContext() {
        log.info("MambaETL base Module willRefreshContext");
        super.willRefreshContext();
    }

    @Override
    public void willStart() {
        log.info("MambaETL base Module willStart");
        super.willStart();
    }

    @Override
    public void willStop() {
        log.info("MambaETL base Module willStop");
        super.willStop();
    }

    /**
     * Register a new OpenMRS task
     *
     * @param name        the name
     * @param description the description
     * @param clazz       the task class
     * @param interval    the interval in seconds
     * @return boolean true if successful, else false
     * @throws SchedulerException if task could not be scheduled
     */
    private boolean registerTask(String name,
                                 String description,
                                 Class<? extends Task> clazz,
                                 long interval,
                                 boolean startOnStartup) {
        try {
            Context.addProxyPrivilege("Manage Scheduler");

            TaskDefinition taskDef = Context.getSchedulerService().getTaskByName(name);
            if (taskDef == null) {
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.MINUTE, 20);
                taskDef = new TaskDefinition();
                taskDef.setTaskClass(clazz.getCanonicalName());
                taskDef.setStartOnStartup(startOnStartup);
                taskDef.setRepeatInterval(interval);
                taskDef.setStarted(true);
                taskDef.setStartTime(cal.getTime());
                taskDef.setName(name);
                taskDef.setUuid(UUID.randomUUID().toString());
                taskDef.setDescription(description);
                Context.getSchedulerService().scheduleTask(taskDef);
            }
            log.info("A Task '" + name + "' has been Registered Successfully!");
        } catch (SchedulerException ex) {
            log.warn("Unable to register task '" + name + "' with scheduler", ex);
            return false;
        } finally {
            Context.removeProxyPrivilege("Manage Scheduler");
        }
        return true;
    }
}
