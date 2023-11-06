DELIMITER //
DROP FUNCTION IF EXISTS JSON_LENGTH_5_6;
CREATE FUNCTION JSON_LENGTH_5_6(json_array TEXT) RETURNS INT
BEGIN
    DECLARE element_count INT DEFAULT 0;
    DECLARE current_position INT DEFAULT 1;

    WHILE current_position <= LENGTH(json_array) DO
        SET element_count = element_count + 1;
        SET current_position = LOCATE(',', json_array, current_position) + 1;

        IF current_position = 0 THEN
            RETURN element_count;
        END IF;
    END WHILE;

RETURN element_count;
END //

DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS JSON_ARRAY_LENGTH;

CREATE FUNCTION JSON_ARRAY_LENGTH(json_array TEXT) RETURNS INT
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

DELIMITER //

DROP FUNCTION IF EXISTS JSON_OBJECT_AT_INDEX;
CREATE FUNCTION JSON_OBJECT_AT_INDEX(json_array TEXT, index_pos INT) RETURNS TEXT
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


DELIMITER //
DROP FUNCTION IF EXISTS ARRAY_LENGTH;
CREATE FUNCTION ARRAY_LENGTH(array_string TEXT) RETURNS INT
BEGIN
  DECLARE length INT DEFAULT 0;
  DECLARE i INT DEFAULT 1;

  -- If the array_string is not empty, initialize length to 1
  IF TRIM(array_string) != '' AND TRIM(array_string) != '[]' THEN
    SET length = 1;
END IF;

  -- Count the number of commas in the array string
  WHILE i <= CHAR_LENGTH(array_string) DO
    IF SUBSTRING(array_string, i, 1) = ',' THEN
      SET length = length + 1;
END IF;
    SET i = i + 1;
END WHILE;

RETURN length;
END //

DELIMITER ;


