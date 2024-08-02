/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore;

import org.openmrs.api.context.Context;
import org.openmrs.module.BaseModuleActivator;
import org.openmrs.module.mambacore.task.FlattenTableTask;
import org.openmrs.scheduler.SchedulerException;
import org.openmrs.scheduler.TaskDefinition;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Calendar;
import java.util.UUID;

/**
 * This class contains the logic that is run every time
 * this module is either started or shutdown
 */
public class MambaCoreActivator extends BaseModuleActivator {

    private static final Logger log = LoggerFactory.getLogger(MambaCoreActivator.class);

    public MambaCoreActivator() {
        super();
    }

    @Override
    public void started() {
        log.info("log MambaCoreActivator started()");
    }

    @Override
    public void stopped() {
        super.stopped();
    }

    @Override
    public void willRefreshContext() {
        super.willRefreshContext();
    }

    @Override
    public void willStart() {
        super.willStart();
    }

    @Override
    public void willStop() {
        super.willStop();
    }

    @Override
    public void contextRefreshed() {
        log.info("log MambaCoreActivator contextRefreshed()");
    }

    /**
     * Register a new OpenMRS task
     */
    private void registerTask() {
        try {
            Context.addProxyPrivilege("Manage Scheduler");

            TaskDefinition taskDef = Context.getSchedulerService().getTaskByName("MambaETL Task");
            if (taskDef == null) {
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.MINUTE, 5);
                taskDef = new TaskDefinition();
                taskDef.setTaskClass(FlattenTableTask.class.getCanonicalName());
                taskDef.setStartOnStartup(true);
                taskDef.setStarted(true);
                taskDef.setStartTime(cal.getTime());
                taskDef.setUuid(UUID.randomUUID().toString());
                taskDef.setName("Mamba-ETL Task");
                taskDef.setDescription("MambaETL Task - To Flatten and Prepare Reporting Data.");
                Context.getSchedulerService().scheduleTask(taskDef);
                log.info("Task {} has been successfully registered", "MambaETL Task");
            }
        } catch (SchedulerException ex) {
            log.error("Unable to register Task", ex);
        } finally {
            Context.removeProxyPrivilege("Manage Scheduler");
        }
    }
}