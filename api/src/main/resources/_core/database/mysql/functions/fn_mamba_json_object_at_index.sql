DROP FUNCTION IF EXISTS fn_mamba_json_object_at_index;
DELIMITER //

CREATE FUNCTION fn_mamba_json_object_at_index(json_array TEXT, index_pos INT) RETURNS TEXT
    DETERMINISTIC
BEGIN
  DECLARE obj_start INT DEFAULT 1;
  DECLARE obj_end INT DEFAULT 1;
  DECLARE current_index INT DEFAULT 0;
  DECLARE obj_text TEXT;

    -- Handle negative index_pos or json_array being NULL
    IF index_pos < 1 OR json_array IS NULL THEN
        RETURN NULL;
    END IF;

    -- Find the start of the requested object
    WHILE obj_start < CHAR_LENGTH(json_array) AND current_index < index_pos DO
        SET obj_start = LOCATE('{', json_array, obj_end);

        -- If we can't find a new object, return NULL
        IF obj_start = 0 THEN
          RETURN NULL;
        END IF;

        SET current_index = current_index + 1;
        -- If this isn't the object we want, find the end and continue
        IF current_index < index_pos THEN
          SET obj_end = LOCATE('}', json_array, obj_start) + 1;
        END IF;
    END WHILE;

    -- Now obj_start points to the start of the desired object
    -- Find the end of it
    SET obj_end = LOCATE('}', json_array, obj_start);
    IF obj_end = 0 THEN
        -- The object is not well-formed
        RETURN NULL;
    END IF;

    -- Extract the object
    SET obj_text = SUBSTRING(json_array, obj_start, obj_end - obj_start + 1);

RETURN obj_text;
END //

DELIMITER ;