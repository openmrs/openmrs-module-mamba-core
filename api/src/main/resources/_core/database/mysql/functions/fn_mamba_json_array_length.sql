DROP FUNCTION IF EXISTS fn_mamba_json_array_length;
DELIMITER //

CREATE FUNCTION fn_mamba_json_array_length(json_array TEXT) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE array_length INT DEFAULT 0;
    DECLARE current_pos INT DEFAULT 1;
    DECLARE char_val CHAR(1);

    IF json_array IS NULL THEN
        RETURN 0;
    END IF;

  -- Iterate over the string to count the number of objects based on commas and curly braces
    WHILE current_pos <= CHAR_LENGTH(json_array) DO
        SET char_val = SUBSTRING(json_array, current_pos, 1);

    -- Check for the start of an object
        IF char_val = '{' THEN
            SET array_length = array_length + 1;

      -- Move current_pos to the end of this object
            SET current_pos = LOCATE('}', json_array, current_pos) + 1;
        ELSE
            SET current_pos = current_pos + 1;
        END IF;
    END WHILE;

RETURN array_length;
END //

DELIMITER ;