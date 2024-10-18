package com.ayinza.util.debezium.application.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.slf4j.Logger;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Map;

@ApplicationScoped
public class OffsetUtils {

    @Inject
    private Logger logger;

    /**
     * Transforms the specified offset file to match the new expected structure after the debezium and
     * kafka upgrades in previous versions.
     *
     * @param offset the offset data
     * @throws IOException
     */
    public void transformOffsetIfNecessary(Map<ByteBuffer, ByteBuffer> offset)
            throws IOException {

        if (offset.isEmpty()) {
            logger.debug("No existing offset file found, skipping offset transformation check");
            return;
        }

        ObjectMapper mapper = new ObjectMapper();
        ByteBuffer keyByteBuf = offset.keySet().iterator().next();
        ByteBuffer valueByteBuf = offset.get(keyByteBuf);
        JsonNode keyNode = mapper.readValue(keyByteBuf.array(), JsonNode.class);
        if (keyNode.isObject()) {
            logger.info("Transforming offset to structure that conforms to the new kafka API");
            offset.remove(keyByteBuf);
            byte[] newKeyBytes = mapper.writeValueAsBytes(keyNode.get("payload"));
            offset.put(ByteBuffer.wrap(newKeyBytes), valueByteBuf);
        }
    }
}
