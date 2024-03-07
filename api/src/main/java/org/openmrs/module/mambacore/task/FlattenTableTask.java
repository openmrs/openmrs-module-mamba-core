/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.task;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.scheduler.tasks.AbstractTask;

public class FlattenTableTask extends AbstractTask {

    private final static Logger log = LoggerFactory.getLogger(FlattenTableTask.class);

    @Override
    public void execute() {

        log.info("MambaETL FlattenTableTask starting to execute!..");

        if (!isExecuting) {

            startExecuting();

            try {
                getService().flattenDatabase();
            } catch (Exception e) {
                log.error("Error while running MambaETL FlattenTableTask: ", e);
            } finally {
                stopExecuting();
                log.info("MambaETL FlattenTableTask completed & stopped...");
            }
        } else {
            log.error("Warning, an instance of MambaETL Flattening Task is still running, try again after");
        }
    }

    private FlattenDatabaseService getService() {
        return Context.getService(FlattenDatabaseService.class);
    }
}
