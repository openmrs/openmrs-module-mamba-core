/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.debezium;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DbEventConsumerImpl implements EventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(DbEventConsumerImpl.class);

    @Override
    public void accept(DbEvent dbEvent) {

        logger.debug("DEBEZIUM Processing DbEvent: " + dbEvent);

        if (dbEvent.isSchemaEvent()) {
            DbSchemaEvent event = (DbSchemaEvent) dbEvent;
        } else {
            DbCrudEvent event = (DbCrudEvent) dbEvent;
            logger.debug("DEBEZIUM Processing DbSchemaEvent Table affected: " + event.getTableName()
                    + " - Operation: " + event.getOperation());
        }
    }

    @Override
    public void preStartup() {
        EventConsumer.super.preStartup();
    }

    @Override
    public void preShutdown() {
        EventConsumer.super.preShutdown();
    }

    @Override
    public void preReset() {
        EventConsumer.super.preReset();
    }
}
