DELIMITER //
DROP FUNCTION IF EXISTS JSON_KEYS_ARRAY;
CREATE FUNCTION JSON_KEYS_ARRAY(json_object TEXT) RETURNS TEXT
BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE start_index INT DEFAULT 1;
    DECLARE end_index INT DEFAULT 1;
    DECLARE key_name TEXT DEFAULT '';
    DECLARE my_keys TEXT DEFAULT '';
    DECLARE json_length INT;
    DECLARE key_end_index INT;

    SET json_length = CHAR_LENGTH(json_object);

    -- Initialize the my_keys string as an empty 'array'
    SET my_keys = '';

    -- This loop goes through the JSON object and extracts the my_keys
    WHILE NOT finished DO
            -- Find the start of the key
            SET start_index = LOCATE('"', json_object, end_index);
            IF start_index = 0 OR start_index >= json_length THEN
                SET finished = 1;
            ELSE
                -- Find the end of the key
                SET end_index = LOCATE('"', json_object, start_index + 1);
                SET key_name = SUBSTRING(json_object, start_index + 1, end_index - start_index - 1);

                -- Append the key to the 'array' of my_keys
                IF my_keys = ''
                    THEN
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
            END IF;
        END WHILE;

    -- Close the 'array' of my_keys
    IF my_keys != '' THEN
        SET my_keys = CONCAT(my_keys, ']');
    END IF;

    RETURN my_keys;
END //

DELIMITER ;
