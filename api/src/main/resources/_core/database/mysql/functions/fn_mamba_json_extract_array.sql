DROP FUNCTION IF EXISTS fn_mamba_json_extract_array;

DELIMITER //

CREATE FUNCTION fn_mamba_json_extract_array(json TEXT, key_name VARCHAR(255))
    RETURNS TEXT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Extracts an array from a JSON string by key name'

BEGIN
    DECLARE start_index INT;
    DECLARE end_index INT;
    DECLARE array_text TEXT;
    DECLARE bracket_counter INT;

    -- Handle NULL inputs
    IF json IS NULL OR key_name IS NULL THEN
        RETURN NULL;
    END IF;

    -- Use native JSON functions for MySQL 8.0+
    IF fn_mamba_is_mysql8_or_higher() THEN
        -- Use built-in JSON functions for better performance and accuracy
        -- Check if the extracted value is an array
        IF JSON_VALID(json) AND JSON_TYPE(JSON_EXTRACT(json, CONCAT('$.', key_name))) = 'ARRAY' THEN
            -- Return the array without the surrounding quotes
            RETURN JSON_EXTRACT(json, CONCAT('$.', key_name));
        ELSE
            RETURN NULL;
        END IF;
    ELSE
        -- Fallback for MySQL 5.7 and earlier - manual JSON parsing

        -- Basic validation - check if it looks like an object
        IF NOT (json LIKE '{%}') THEN
            RETURN NULL;
        END IF;

        -- Add the key structure to search for in the JSON string
        SET key_name = CONCAT('"', key_name, '":');
        SET start_index = LOCATE(key_name, json);

        IF start_index = 0 THEN
            RETURN NULL;
        END IF;

        SET start_index = start_index + CHAR_LENGTH(key_name);

        -- Skip any whitespace
        WHILE SUBSTRING(json, start_index, 1) IN (' ', '\t', '\n', '\r')
            DO
                SET start_index = start_index + 1;
            END WHILE;

        -- Check if we're looking at an array
        IF SUBSTRING(json, start_index, 1) != '[' THEN
            RETURN NULL;
        END IF;

        -- Find the matching closing bracket
        SET start_index = start_index; -- Keep the opening bracket
        SET end_index = start_index;
        SET bracket_counter = 1;

        WHILE bracket_counter > 0 AND end_index < CHAR_LENGTH(json)
            DO
                SET end_index = end_index + 1;
                IF SUBSTRING(json, end_index, 1) = '[' THEN
                    SET bracket_counter = bracket_counter + 1;
                ELSEIF SUBSTRING(json, end_index, 1) = ']' THEN
                    SET bracket_counter = bracket_counter - 1;
                END IF;
            END WHILE;

        IF bracket_counter != 0 THEN
            RETURN NULL; -- The brackets are not balanced, return NULL
        END IF;

        -- Include the closing bracket in the result
        SET array_text = SUBSTRING(json, start_index, end_index - start_index + 1);

        RETURN array_text;
    END IF;
END //

DELIMITER ;