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

    private static final Logger log = LoggerFactory.getLogger(RocksDBOffsetBackingStore.class);

    private RocksDB db;

    public RocksDBOffsetBackingStore() {
        RocksDB.loadLibrary();
    }

    @Override
    public void configure(WorkerConfig config) {

        try {
            log.debug("Configuring RocksDBOffsetBackingStore...");
            Options options = new Options().setCreateIfMissing(true);
            db = RocksDB.open(options, "/tmp/rocksdb");
        } catch (Exception e) {
            log.error("Error while configuring RocksDB", e);
            throw new RuntimeException(e);
        }
    }

    public RocksDB getDb() {
        return db;
    }

    @Override
    public void start() {
        log.debug("Starting RocksDBOffsetBackingStore...");
    }

    @Override
    public void stop() {
        log.debug("Stopping RocksDBOffsetBackingStore...");
        if (db != null) {
            try {
                db.close();
            } catch (Exception e) {
                log.error("Error while closing RocksDB", e);
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
}