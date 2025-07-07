DROP FUNCTION IF EXISTS fn_mamba_json_extract;

DELIMITER //

CREATE FUNCTION fn_mamba_json_extract(json TEXT, key_name VARCHAR(255))
    RETURNS VARCHAR(255)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Extracts a value from a JSON string by key name'

BEGIN
    DECLARE start_index INT;
    DECLARE end_index INT;
    DECLARE key_length INT;
    DECLARE key_index INT;

    -- Handle NULL inputs
    IF json IS NULL OR key_name IS NULL THEN
        RETURN NULL;
    END IF;

    -- Use native JSON functions for MySQL 8.0+
    IF fn_mamba_is_mysql8_or_higher() THEN
        -- Use built-in JSON functions for better performance and accuracy
        RETURN JSON_EXTRACT(json, CONCAT('$.', key_name));
    ELSE
        -- Fallback for MySQL 5.7 and earlier - manual JSON parsing

        -- Basic validation - check if it looks like an object
        IF NOT (json LIKE '{%}') THEN
            RETURN NULL;
        END IF;

        -- Add the key structure to search for in the JSON string
        SET key_name = CONCAT('"', key_name, '":');
        SET key_length = CHAR_LENGTH(key_name);
        SET key_index = LOCATE(key_name, json);

        IF key_index = 0 THEN
            RETURN NULL;
        END IF;

        SET start_index = key_index + key_length;

        CASE
            WHEN SUBSTRING(json, start_index, 1) = '"' THEN SET start_index = start_index + 1;
                                                            SET end_index = LOCATE('"', json, start_index);
            ELSE SET end_index = LOCATE(',', json, start_index);
                 IF end_index = 0 THEN
                     SET end_index = LOCATE('}', json, start_index);
                 END IF;
            END CASE;

        -- Handle case where end marker wasn't found
        IF end_index = 0 THEN
            RETURN NULL;
        END IF;

        RETURN SUBSTRING(json, start_index, end_index - start_index);
    END IF;
END //

DELIMITER ;