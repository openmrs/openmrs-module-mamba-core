package org.openmrs.module.mambacore.db.debezium;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Map;

public class OffsetUtils {

    private final static Logger logger = LoggerFactory.getLogger(OffsetUtils.class);

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
