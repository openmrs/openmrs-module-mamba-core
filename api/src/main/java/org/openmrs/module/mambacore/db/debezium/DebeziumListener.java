//package org.openmrs.module.mambacore.db.debezium;
//
//import com.fasterxml.jackson.databind.ObjectMapper;
//import io.debezium.config.Configuration;
//import io.debezium.engine.ChangeEvent;
//import io.debezium.engine.DebeziumEngine;
//import io.debezium.engine.format.Json;
//
//import java.util.Map;
//
//public class DebeziumListener {
//
//    private final DebeziumEventService debeziumEventService;
//    private final ObjectMapper objectMapper;
//
//    public DebeziumListener() {
//        this.debeziumEventService = new DebeziumEventService();
//        this.objectMapper = new ObjectMapper(); // Initialize Jackson ObjectMapper for JSON parsing
//    }
//
//    public void startListening() {
//        // Step 1: Get the configuration from DebeziumConfigProvider
//        Configuration config = DebeziumConfigProvider
//                .getInstance()
//                .build();
//
//        // Step 2: Set up the Debezium Engine to capture JSON events
//        DebeziumEngine<ChangeEvent<String, String>> engine = DebeziumEngine.create(Json.class)
//                .using(config.asProperties())
//                .notifying(this::handleDebeziumEvent)
//                .build();
//
//        // Step 3: Run the Debezium Engine in a separate thread
////        ExecutorService executor = Executors.newSingleThreadExecutor();
////        executor.submit(engine);
//
//        // Step 4: Gracefully shutdown the engine on JVM exit
//        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
//            try {
//                engine.close();
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
//        }));
//    }
//
//    private void handleDebeziumEvent(ChangeEvent<String, String> event) {
//        try {
//            // Step 5: Parse the JSON string from the event
//            String jsonString = event.value();
//            if (jsonString == null) {
//                return; // Ignore empty events
//            }
//
//            // Convert the JSON string into a Map using Jackson ObjectMapper
//            Map<String, Object> changeEvent = objectMapper.readValue(jsonString, Map.class);
//
//            // Step 6: Delegate the event to the service for transactional handling
//            debeziumEventService.processDebeziumEvent(changeEvent);
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//}