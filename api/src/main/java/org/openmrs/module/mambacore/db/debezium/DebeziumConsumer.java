package org.openmrs.module.mambacore.db.debezium;

import io.debezium.engine.ChangeEvent;
import org.apache.kafka.connect.source.SourceRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.function.Consumer;
import java.util.function.Function;

/**
 * Implementation of a Debezium ChangeEvent consumer, which abstracts the Debezium API behind a DbEvent
 * and ensures that the registered DbEvent EventConsumer is successfully processed before moving onto the next
 * record, with a configurable retryInterval upon failure.
 */
public class DebeziumConsumer implements Consumer<ChangeEvent<SourceRecord, SourceRecord>> {

    protected static final Logger logger = LoggerFactory.getLogger(DebeziumConsumer.class);

    private final DbEventSourceConfig eventSourceConfig;

    private final EventConsumer eventConsumer;
    private boolean stopped = false;
    private boolean disabled = false;

    private Function<ChangeEvent<SourceRecord, SourceRecord>, DbEvent> function = new DbChangeToEvent();

    public DebeziumConsumer(EventConsumer eventConsumer, DbEventSourceConfig eventSourceConfig) {
        this.eventConsumer = eventConsumer;
        this.eventSourceConfig = eventSourceConfig;
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

        DbEventStatus status = null;
        try {
            if (disabled) {
                logger.error("The Debezium consumer has been stopped prior to processing: " + changeEvent);
                return;
            }

            DbEvent dbEvent = function.apply(changeEvent);
            logger.debug("Notifying listener of the database event: " + dbEvent);

            eventConsumer.accept(dbEvent);

            status = DbEventLog.logger(event);
            status.setProcessed(true);
        } catch (Throwable t) {
            logger.error("An error occurred processing change event: " + changeEvent, t);
            if (status != null) {
                status.setError(t);
            }
            //TODO Do not disable in case of a snapshot event
            disabled = true;
            CustomFileOffsetBackingStore.disable();
        }
    }

    public void cancel() {
        this.disabled = true;
    }
}
