package org.openmrs.module.mambacore.db.debezium;

import java.util.function.Consumer;

/**
 * Implement this interface to provide logic for handing Events from a DbEventSource
 */
public interface EventConsumer extends Consumer<DbEvent> {

    /**
     * Executed at startup (prior to any Event processing)
     */
    default void preStartup() {
    }

    /**
     * Executed at shutdown
     */
    default void preShutdown() {
    }
}
