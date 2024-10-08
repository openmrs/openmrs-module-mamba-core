//package org.openmrs.module.mambacore.db.debezium;
//
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//
//import java.util.Map;
//
//public class DebeziumEventService {
//
//    private static final Logger log = LoggerFactory.getLogger(DebeziumEventService.class);
//
//    public DebeziumEventService() {
//    }
//
//    public void processDebeziumEvent(Map<String, Object> changeEvent) {
//        // Similar logic to handle insert, update, and delete events
//        // Extract and process data from the event map
//        Map<String, Object> payload = (Map<String, Object>) changeEvent.get("payload");
//        if (payload == null) {
//            return;
//        }
//        System.out.println("Payload: " + payload);
//
//        String operation = (String) payload.get("op");
//        Map<String, Object> source = (Map<String, Object>) payload.get("source");
//        String databaseName = (String) source.get("db");
//        String tableName = (String) source.get("table");
//
//        Map<String, Object> before = (Map<String, Object>) payload.get("before");
//        Map<String, Object> after = (Map<String, Object>) payload.get("after");
//
//        switch (operation) {
//
//            case "c": // INSERT
//                System.out.println("INSERT event captured on " + databaseName + "." + tableName);
//                System.out.println("New row data: " + after);
//                break;
//
//            case "u": // UPDATE
//                System.out.println("UPDATE event captured on " + databaseName + "." + tableName);
//                System.out.println("Before: " + before);
//                System.out.println("After: " + after);
//                break;
//
//            case "d": // DELETE
//                System.out.println("DELETE event captured on " + databaseName + "." + tableName);
//                System.out.println("Deleted row data: " + before);
//                break;
//
//            default:
//                System.out.println("Unknown event type: " + operation);
//        }
//    }
//}