package org.openmrs.module.mambacore.db.debezium;

import io.debezium.engine.ChangeEvent;
import org.openmrs.module.dbevent.DbEvent;
import org.openmrs.module.dbevent.EventConsumer;

public class MyEventConsumer implements EventConsumer {

    @Override
    public void accept(DbEvent dbEvent) {
        // Process the DbEvent (e.g., log it, update another system)
        System.out.println("DbEvent detected: " + dbEvent);
    }
}