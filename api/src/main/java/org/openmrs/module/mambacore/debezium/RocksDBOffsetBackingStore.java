package org.openmrs.module.mambacore.debezium;

import org.apache.kafka.connect.runtime.WorkerConfig;
import org.apache.kafka.connect.storage.OffsetBackingStore;
import org.apache.kafka.connect.util.Callback;
import org.rocksdb.Options;
import org.rocksdb.RocksDB;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.ByteBuffer;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

public class RocksDBOffsetBackingStore implements OffsetBackingStore, AutoCloseable {

    private static final Logger logger = LoggerFactory.getLogger(RocksDBOffsetBackingStore.class);

    private RocksDB db;

    public RocksDBOffsetBackingStore() { //TODO: change this implementation
        RocksDB.loadLibrary();
    }

    public static RocksDBOffsetBackingStore getInstance() {
        return SingletonHelper.INSTANCE;
    }

    @Override
    public void configure(WorkerConfig config) {
        try {
            logger.debug("Configuring RocksDBOffsetBackingStore...");
            Options options = new Options().setCreateIfMissing(true);
            db = RocksDB.open(options, "/tmp/rocksdb");
        } catch (Exception e) {
            logger.error("Error while configuring RocksDB", e);
            throw new RuntimeException(e);
        }
    }

    public RocksDB getDb() {
        return db;
    }

    @Override
    public void start() {
        logger.debug("Starting RocksDBOffsetBackingStore...");
    }

    @Override
    public void stop() {
        logger.debug("Stopping RocksDBOffsetBackingStore...");
        if (db != null) {
            try {
                db.close();
            } catch (Exception e) {
                logger.error("Error while closing RocksDB", e);
                throw new RuntimeException(e);
            } finally {
                db = null;
            }
        }
    }

    @Override
    public Future<Map<ByteBuffer, ByteBuffer>> get(Collection<ByteBuffer> keys) {
        return CompletableFuture.supplyAsync(() -> {
            Map<ByteBuffer, ByteBuffer> result = new HashMap<>();
            try {
                for (ByteBuffer key : keys) {
                    byte[] value = db.get(key.array());
                    if (value != null) {
                        result.put(key, ByteBuffer.wrap(value));
                    }
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            return result;
        });
    }

    @Override
    public Future<Void> set(Map<ByteBuffer, ByteBuffer> offsets, Callback<Void> callback) {
        return CompletableFuture.runAsync(() -> {
            try {
                offsets.forEach((key, value) -> {
                    try {
                        db.put(key.array(), value.array());
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                });
                callback.onCompletion(null, null);
            } catch (Exception e) {
                callback.onCompletion(e, null);
            }
        });
    }

    @Override
    public void close() throws Exception {
        stop();  // Delegate to stop() to ensure cleanup is handled in one place
    }

    // Static inner helper class for lazy-loaded, thread-safe singleton instance
    private static class SingletonHelper {
        private static final RocksDBOffsetBackingStore INSTANCE = new RocksDBOffsetBackingStore();
    }
}