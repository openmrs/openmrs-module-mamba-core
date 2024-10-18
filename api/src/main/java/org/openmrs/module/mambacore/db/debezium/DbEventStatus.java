package com.ayinza.util.debezium.domain.model;

import java.time.Instant;
import java.util.Optional;

/**
 * This class represents the status of a particular event.
 * It allows tracking events as they are streamed and provides information on any errors associated.
 */
public class DbEventStatus {

    private final DbEvent event;
    private volatile Throwable error;
    private volatile Instant timestamp;
    private volatile boolean processed;

    /**
     * Constructs a DbEventStatus object for a given event and sets the initial timestamp.
     *
     * @param event the event being tracked
     */
    public DbEventStatus(DbEvent event) {
        this.event = event;
        this.timestamp = Instant.now();
        this.processed = false;
    }

    /**
     * Gets the associated event.
     *
     * @return the event being tracked
     */
    public DbEvent getEvent() {
        return event;
    }

    /**
     * Checks if the event has been processed.
     *
     * @return true if the event is processed, false otherwise
     */
    public boolean isProcessed() {
        return processed;
    }

    /**
     * Marks the event as processed.
     *
     * @param processed whether the event is processed or not
     * @return the updated DbEventStatus object for method chaining
     */
    public DbEventStatus setProcessed(boolean processed) {
        this.processed = processed;
        return this;
    }

    /**
     * Gets the error associated with the event, if any.
     *
     * @return an Optional containing the error, or an empty Optional if no error exists
     */
    public Optional<Throwable> getError() {
        return Optional.ofNullable(error);
    }

    /**
     * Sets an error for the event.
     *
     * @param error the error encountered during event processing
     * @return the updated DbEventStatus object for method chaining
     */
    public DbEventStatus setError(Throwable error) {
        this.error = error;
        return this;
    }

    /**
     * Gets the timestamp of when this status was created or last updated.
     *
     * @return the timestamp as an Instant
     */
    public Instant getTimestamp() {
        return timestamp;
    }

    /**
     * Updates the timestamp to the specified value.
     *
     * @param timestamp the new timestamp
     * @return the updated DbEventStatus object for method chaining
     */
    public DbEventStatus setTimestamp(Instant timestamp) {
        this.timestamp = timestamp;
        return this;
    }

    /**
     * Updates the timestamp to the current time.
     *
     * @return the updated DbEventStatus object for method chaining
     */
    public DbEventStatus updateTimestamp() {
        this.timestamp = Instant.now();
        return this;
    }
}