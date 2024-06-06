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
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * This class contains the logic that is run every time
 * this module is either started or shutdown
 */
public class MambaCoreActivator extends BaseModuleActivator {

    private static final Logger log = LoggerFactory.getLogger(MambaCoreActivator.class);

    public MambaCoreActivator() {

        super();
        log.info("MambaCoreActivator constructor");
    }

    public void started() {
        log.info("about to invoke: invokeEventScheduler");
        Context.getService(FlattenDatabaseService.class).flattenDatabase();
        log.info("Done invoking: invokeEventScheduler");
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
}