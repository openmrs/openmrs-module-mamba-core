DROP FUNCTION IF EXISTS fn_mamba_json_keys_array;

DELIMITER //

CREATE FUNCTION fn_mamba_json_keys_array(json_object TEXT)
    RETURNS TEXT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Extracts all keys from a JSON object and returns them as a JSON array'

BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE start_index INT DEFAULT 1;
    DECLARE end_index INT DEFAULT 1;
    DECLARE key_name TEXT DEFAULT '';
    DECLARE my_keys TEXT DEFAULT '';
    DECLARE json_length INT;
    DECLARE key_end_index INT;

    -- Handle NULL input
    IF json_object IS NULL THEN
        RETURN NULL;
    END IF;

    -- Use native JSON functions for MySQL 8.0+
    IF fn_mamba_is_mysql8_or_higher() THEN
        -- Check if input is a valid JSON object
        IF JSON_VALID(json_object) AND JSON_TYPE(json_object) = 'OBJECT' THEN
            RETURN JSON_KEYS(json_object);
        ELSE
            RETURN NULL;
        END IF;
    ELSE
        -- Fallback for MySQL 5.7 and earlier - manual extraction

        -- Basic validation - check if it looks like an object
        IF NOT (json_object LIKE '{%}') THEN
            RETURN NULL;
        END IF;

        SET json_length = CHAR_LENGTH(json_object);

        -- Initialize the my_keys string as an empty 'array'
        SET my_keys = '';

        -- This loop goes through the JSON object and extracts the keys
        WHILE NOT finished
            DO
                -- Find the start of the key
                SET start_index = LOCATE('"', json_object, end_index);
                IF start_index = 0 OR start_index >= json_length THEN
                    SET finished = 1;
                ELSE
                    -- Find the end of the key
                    SET end_index = LOCATE('"', json_object, start_index + 1);
                    IF end_index = 0 THEN
                        -- Malformed JSON - missing closing quote
                        SET finished = 1;
                    ELSE
                        -- Check if this is actually a key (followed by a colon)
                        IF LOCATE(':', json_object, end_index) = end_index + 1 THEN
                            SET key_name = SUBSTRING(json_object, start_index + 1, end_index - start_index - 1);

                            -- Append the key to the 'array' of keys
                            IF my_keys = '' THEN
                                SET my_keys = CONCAT('["', key_name, '"');
                            ELSE
                                SET my_keys = CONCAT(my_keys, ',"', key_name, '"');
                            END IF;

                            -- Move past the current key-value pair
                            SET key_end_index = LOCATE(',', json_object, end_index);
                            IF key_end_index = 0 THEN
                                SET key_end_index = LOCATE('}', json_object, end_index);
                            END IF;
                            IF key_end_index = 0 THEN
                                -- Closing brace not found - malformed JSON
                                SET finished = 1;
                            ELSE
                                -- Prepare for the next iteration
                                SET end_index = key_end_index + 1;
                            END IF;
                        ELSE
                            -- This is not a key (no colon after the quote)
                            -- Move to the next quote
                            SET end_index = end_index + 1;
                        END IF;
                    END IF;
                END IF;
            END WHILE;

        -- Close the 'array' of keys
        IF my_keys != '' THEN
            SET my_keys = CONCAT(my_keys, ']');
        END IF;

        RETURN my_keys;
    END IF;
END //

DELIMITER ;