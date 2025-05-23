DROP FUNCTION IF EXISTS fn_mamba_json_value_by_key;

DELIMITER //

CREATE FUNCTION fn_mamba_json_value_by_key(json TEXT, key_name VARCHAR(255))
    RETURNS VARCHAR(255)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Extracts a value from a JSON string by key name'

BEGIN
    DECLARE start_index INT;
    DECLARE end_index INT;
    DECLARE key_length INT;
    DECLARE key_index INT;
    DECLARE value_length INT;
    DECLARE extracted_value VARCHAR(255);

    -- Handle NULL inputs
    IF json IS NULL OR key_name IS NULL THEN
        RETURN NULL;
    END IF;

    -- Use JSON_EXTRACT for MySQL 8.0+
    IF fn_mamba_is_mysql8_or_higher() THEN
        -- Use built-in JSON functions for better performance and accuracy
        RETURN JSON_UNQUOTE(JSON_EXTRACT(json, CONCAT('$.', key_name)));
    ELSE
        -- Fallback for MySQL 5.7 and earlier - manual JSON parsing

        -- Add the key structure to search for in the JSON string
        SET key_name = CONCAT('"', key_name, '":');
        SET key_length = CHAR_LENGTH(key_name);

        -- Locate the key within the JSON string
        SET key_index = LOCATE(key_name, json);

        -- If the key is not found, return NULL
        IF key_index = 0 THEN
            RETURN NULL;
        END IF;

        -- Set the starting index of the value
        SET start_index = key_index + key_length;

        -- Check if the value is a string (starts with a quote)
        IF SUBSTRING(json, start_index, 1) = '"' THEN
            -- Set the start index to the first character of the value (skipping the quote)
            SET start_index = start_index + 1;

            -- Find the end of the string value (the next quote)
            SET end_index = LOCATE('"', json, start_index);
            IF end_index = 0 THEN
                -- If there's no end quote, the JSON is malformed
                RETURN NULL;
            END IF;
        ELSE
            -- The value is not a string (e.g., a number, boolean, or null)
            -- Find the end of the value (either a comma or closing brace)
            SET end_index = LOCATE(',', json, start_index);
            IF end_index = 0 THEN
                SET end_index = LOCATE('}', json, start_index);
            END IF;
        END IF;

        -- Calculate the length of the extracted value
        SET value_length = end_index - start_index;

        -- Extract the value
        SET extracted_value = SUBSTRING(json, start_index, value_length);

        -- Return the extracted value without leading or trailing quotes
        RETURN TRIM(BOTH '"' FROM extracted_value);
    END IF;
END //

DELIMITER ;