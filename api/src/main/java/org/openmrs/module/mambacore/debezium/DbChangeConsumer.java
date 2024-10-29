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

import io.debezium.engine.ChangeEvent;
import org.apache.kafka.connect.source.SourceRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DbChangeConsumer implements DbChangeListener {

    private static final Logger logger = LoggerFactory.getLogger(DbChangeConsumer.class);

    private final EventConsumer eventConsumer;
    private final DbChangeToEventMapper eventMapper;

    public DbChangeConsumer(EventConsumer eventConsumer, DbChangeToEventMapper eventMapper) {
        this.eventConsumer = eventConsumer;
        this.eventMapper = eventMapper;
    }

    @Override
    public void onDbChange(ChangeEvent<SourceRecord, SourceRecord> changeEvent) {
        try {
            DbEvent dbEvent = eventMapper.apply(changeEvent);
            logger.debug("Notifying listener of the database event: {}", dbEvent);
            eventConsumer.accept(dbEvent);
        } catch (Throwable e) {
            logger.error("Error processing change event: {}", changeEvent, e);
            throw e;
        }
    }
}