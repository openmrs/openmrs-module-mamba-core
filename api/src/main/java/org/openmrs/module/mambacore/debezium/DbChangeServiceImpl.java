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

import io.debezium.config.Configuration;
import io.debezium.embedded.Connect;
import io.debezium.engine.ChangeEvent;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.spi.OffsetCommitPolicy;
import org.apache.kafka.connect.source.SourceRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class DbChangeServiceImpl implements DbChangeService {

    private static final Logger logger = LoggerFactory.getLogger(DbChangeServiceImpl.class);

    private DbChangeConsumer consumer;

    private Configuration debeziumConfig;

    private RocksDBOffsetBackingStore offsetBackingStore;

    private DebeziumEngine<ChangeEvent<SourceRecord, SourceRecord>> engine;

    private ExecutorService executor;

    @Override
    public void start() {

        if (engine != null) {
            logger.warn("Debezium engine is already running.");
            return;
        }

        engine = DebeziumEngine.create(Connect.class)
                .using(debeziumConfig.asProperties())
                .notifying(consumer)
                .using(OffsetCommitPolicy.always())
                .build();

        executor = Executors.newSingleThreadExecutor();
        executor.execute(engine);
        Runtime.getRuntime().addShutdownHook(new Thread(this::stop));

        logger.info("Debezium engine started.");
    }

    @Override
    public void stop() {

        if (engine == null) {
            logger.warn("Debezium engine is not running.");
            return;
        }

        try {
            engine.close();
            executor.shutdown();
            consumer.cancel();
            if (offsetBackingStore != null) {
                offsetBackingStore.stop();
            }

            try {
                while (!this.executor.awaitTermination(5L, TimeUnit.SECONDS)) {
                    logger.info("Waiting 5 seconds for the Debezium engine to shut down...");
                }
            } catch (InterruptedException ie) {
                logger.error("Interrupted while waiting for termination", ie);
                Thread.currentThread().interrupt();
            }

        } catch (Exception e) {
            logger.error("Error stopping Debezium engine", e);
            executor.shutdownNow();
        } finally {
            engine = null;
            executor = null;
        }
    }

    @Override
    public void reset() {
        stop();
        start();
        logger.info("Debezium engine restarted.");
    }
}