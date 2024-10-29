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

import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class DbChangeServiceImpl implements DbChangeService {

    private static final Logger logger = LoggerFactory.getLogger(DbChangeServiceImpl.class);

    private DbChangeConsumer consumer;

    private Configuration debeziumConfig;

    private Optional<DebeziumEngine<ChangeEvent<SourceRecord, SourceRecord>>> engine = Optional.empty();

    private ExecutorService executor;

    private boolean disabled = false; // Flag to track whether the service is disabled

    public DbChangeServiceImpl(DbChangeConsumer consumer,
                               Configuration debeziumConfig) {
        this.consumer = consumer;
        this.debeziumConfig = debeziumConfig;
    }

    @Override
    public void start() {

        if (engine.isPresent()) {
            logger.warn("Debezium engine is already running.");
            return;
        }
        if (disabled) {
            logger.warn("Debezium engine is disabled and cannot be started. Start it manually");
            return;
        }

        engine = Optional.of(DebeziumEngine.create(Connect.class)
                .using(debeziumConfig.asProperties())
                .notifying(consumer)
                .using(OffsetCommitPolicy.always())
                .build());

        executor = Executors.newSingleThreadExecutor();
        executor.execute(engine.get());
        Runtime.getRuntime().addShutdownHook(new Thread(this::stop));

        logger.info("Debezium engine started.");
    }

    @Override
    public void stop() {
        if (!engine.isPresent()) {
            logger.warn("Debezium engine is not running.");
            return;
        }

        try {
            RocksDBOffsetBackingStore.getInstance().stop();
            executor.shutdown();
            engine.get().close();

            if (executor != null) {
                if (!executor.awaitTermination(5L, TimeUnit.SECONDS)) {
                    logger.info("Waiting 5 seconds for the Debezium engine to shut down...");
                    executor.shutdownNow();
                }
            }
        } catch (InterruptedException ie) {
            logger.error("Interrupted while waiting for termination", ie);
            Thread.currentThread().interrupt();
        } catch (Exception e) {
            logger.error("Error stopping Debezium engine", e);
            executor.shutdownNow();
        } finally {
            engine = Optional.empty();
            executor = null;
        }
    }

    @Override
    public void reset() {
        enable(); // Reset enables the service again
        stop();
        start();
        logger.info("Debezium engine restarted.");
    }

    @Override
    public void disable() {
        disabled = true;
        stop();
        logger.warn("Debezium engine disabled due to error.");
    }

    @Override
    public void enable() {
        disabled = false;
        logger.info("Debezium engine enabled.");
    }

    @Override
    public boolean isDisabled() {
        return disabled;
    }
}