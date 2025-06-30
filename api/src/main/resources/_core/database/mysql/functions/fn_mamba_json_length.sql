DROP FUNCTION IF EXISTS fn_mamba_json_length;

DELIMITER //

CREATE FUNCTION fn_mamba_json_length(json_array TEXT)
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Returns the number of elements in a JSON array'

BEGIN
    DECLARE element_count INT DEFAULT 0;
    DECLARE current_position INT DEFAULT 1;

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

        -- Count elements by counting commas and adding 1
        -- This is a simple approach that works for basic arrays
        WHILE current_position <= CHAR_LENGTH(json_array)
            DO
                SET element_count = element_count + 1;
                SET current_position = LOCATE(',', json_array, current_position) + 1;

                IF current_position = 1 THEN
                    -- No more commas found
                    RETURN element_count;
                END IF;
            END WHILE;

        RETURN element_count;
    END IF;
END //

DELIMITER ;