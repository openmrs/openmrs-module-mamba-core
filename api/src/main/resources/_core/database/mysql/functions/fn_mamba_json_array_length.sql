DROP FUNCTION IF EXISTS fn_mamba_json_array_length;

DELIMITER //

CREATE FUNCTION fn_mamba_json_array_length(json_array TEXT)
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Returns the number of objects in a JSON array'

BEGIN
    DECLARE array_length INT DEFAULT 0;
    DECLARE current_pos INT DEFAULT 1;
    DECLARE char_val CHAR(1);
    DECLARE brace_counter INT DEFAULT 0;

    -- Handle NULL input
    IF json_array IS NULL THEN
        RETURN 0;
    END IF;

    -- Use native JSON functions for MySQL 8.0+
    IF fn_mamba_is_mysql8_or_higher() THEN
        -- Check if input is a valid JSON array
        IF JSON_VALID(json_array) AND JSON_TYPE(json_array) = 'ARRAY' THEN
            RETURN JSON_LENGTH(json_array);
        ELSE
            RETURN 0;
        END IF;
    ELSE
        -- Fallback for MySQL 5.7 and earlier - manual counting

        -- Basic validation - check if it looks like an array
        IF NOT (json_array LIKE '[%]') THEN
            RETURN 0;
        END IF;

        -- Iterate over the string to count the number of objects based on commas and curly braces
        WHILE current_pos <= CHAR_LENGTH(json_array)
            DO
                SET char_val = SUBSTRING(json_array, current_pos, 1);

                -- Check for the start of an object
                IF char_val = '{' THEN
                    -- Only count top-level objects
                    IF brace_counter = 0 THEN
                        SET array_length = array_length + 1;
                    END IF;
                    SET brace_counter = brace_counter + 1;
                ELSEIF char_val = '}' THEN
                    SET brace_counter = brace_counter - 1;
                END IF;

                SET current_pos = current_pos + 1;
            END WHILE;

        RETURN array_length;
    END IF;
END //

DELIMITER ;