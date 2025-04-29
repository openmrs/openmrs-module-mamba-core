DROP FUNCTION IF EXISTS fn_mamba_json_extract_object;

DELIMITER //

CREATE FUNCTION fn_mamba_json_extract_object(json_string TEXT, key_name VARCHAR(255))
    RETURNS TEXT
    DETERMINISTIC
    COMMENT 'Extracts a JSON object from a JSON string by key name'

BEGIN
    DECLARE start_index INT;
    DECLARE end_index INT;
    DECLARE nested_level INT DEFAULT 0;
    DECLARE substring_length INT;
    DECLARE key_str VARCHAR(255);
    DECLARE result TEXT DEFAULT '';

    SET key_str := CONCAT('"', key_name, '": {');

    -- Find the start position of the key
    SET start_index := LOCATE(key_str, json_string);
    IF start_index = 0 THEN
        RETURN NULL;
    END IF;

    -- Adjust start_index to the start of the value
    SET start_index := start_index + CHAR_LENGTH(key_str);

    -- Initialize the end_index to start_index
    SET end_index := start_index;

    -- Find the end of the object
    WHILE nested_level >= 0 AND end_index <= CHAR_LENGTH(json_string)
        DO
            SET end_index := end_index + 1;
            SET substring_length := end_index - start_index;

            -- Check for nested objects
            IF SUBSTRING(json_string, end_index, 1) = '{' THEN
                SET nested_level := nested_level + 1;
            ELSEIF SUBSTRING(json_string, end_index, 1) = '}' THEN
                SET nested_level := nested_level - 1;
            END IF;
        END WHILE;

    -- Get the JSON object
    IF nested_level < 0 THEN
        -- We found a matching pair of curly braces
        SET result := SUBSTRING(json_string, start_index, substring_length);
    END IF;

    RETURN result;
END //

DELIMITER ;