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

import java.util.function.Consumer;

/**
 * Implementation of a Debezium ChangeEvent consumer, which abstracts the Debezium API behind a DbCrudEvent
 * and ensures that the registered DbCrudEvent EventConsumer is successfully processed before moving onto the next
 * record, with a configurable retryInterval upon failure.
 **/
public class DbChangeConsumer implements Consumer<ChangeEvent<SourceRecord, SourceRecord>> {

    private static final Logger logger = LoggerFactory.getLogger(DbChangeConsumer.class);

    private final EventConsumer eventConsumer;
    private final DbChangeToEventMapper eventMapper;
    private boolean disabled = false;

    public DbChangeConsumer(EventConsumer eventConsumer, DbChangeToEventMapper eventMapper) {
        this.eventConsumer = eventConsumer;
        this.eventMapper = eventMapper;
    }

    /**
     * This the primary handler for all Debezium-generated change events.  Per the
     * <a href="https://debezium.io/documentation/reference/stable/development/engine.html">Debezium Documentation</a>
     * this function should not throw any exceptions, as these will simply get logged and Debezium will continue onto
     * the next source record.  So if any exception is caught, this logs the Exception, and retries again after
     * a configurable retryInterval, until it passes.  This effectively blocks any subsequent processing.
     *
     * @param changeEvent the Debeziumn generated event to process
     */
    @Override
    public final void accept(ChangeEvent<SourceRecord, SourceRecord> changeEvent) {

        try {
            if (disabled) {
                logger.error("The Debezium consumer has been stopped prior to processing: " + changeEvent);
                return;
            }

            DbEvent dbEvent = eventMapper.apply(changeEvent);
            logger.debug("Notifying listener of the database event: " + dbEvent);
            eventConsumer.accept(dbEvent);
        } catch (Throwable t) {
            logger.error("An error occurred processing change event: " + changeEvent, t);
            disabled = true;
        }
    }

    public void cancel() {
        this.disabled = true;
    }
}
