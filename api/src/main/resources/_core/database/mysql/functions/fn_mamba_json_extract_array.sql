DROP FUNCTION IF EXISTS fn_mamba_json_extract_array;
DELIMITER //

CREATE FUNCTION fn_mamba_json_extract_array(json TEXT, key_name VARCHAR(255)) RETURNS TEXT
    DETERMINISTIC
BEGIN
DECLARE start_index INT;
DECLARE end_index INT;
DECLARE array_text TEXT;

    SET key_name = CONCAT('"', key_name, '":');
    SET start_index = LOCATE(key_name, json);

    IF start_index = 0 THEN
        RETURN NULL;
    END IF;

    SET start_index = start_index + CHAR_LENGTH(key_name);

    IF SUBSTRING(json, start_index, 1) != '[' THEN
        RETURN NULL;
    END IF;

    SET start_index = start_index + 1; -- Start after the '['
    SET end_index = start_index;

    -- Loop to find the matching closing bracket for the array
    SET @bracket_counter = 1;
    WHILE @bracket_counter > 0 AND end_index <= CHAR_LENGTH(json) DO
        SET end_index = end_index + 1;
        IF SUBSTRING(json, end_index, 1) = '[' THEN
          SET @bracket_counter = @bracket_counter + 1;
        ELSEIF SUBSTRING(json, end_index, 1) = ']' THEN
          SET @bracket_counter = @bracket_counter - 1;
        END IF;
    END WHILE;

    IF @bracket_counter != 0 THEN
        RETURN NULL; -- The brackets are not balanced, return NULL
    END IF;

SET array_text = SUBSTRING(json, start_index, end_index - start_index);

RETURN array_text;
END //

DELIMITER ;