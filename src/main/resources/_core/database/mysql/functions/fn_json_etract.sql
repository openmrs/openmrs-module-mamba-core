DELIMITER //

DROP FUNCTION IF EXISTS JSON_EXTRACT_1;
CREATE FUNCTION JSON_EXTRACT_1(json TEXT, key_name VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
  DECLARE start_index INT;
  DECLARE end_index INT;
  DECLARE key_length INT;
  DECLARE key_index INT;

  SET key_name = CONCAT('"', key_name, '":');
  SET key_length = CHAR_LENGTH(key_name);
  SET key_index = LOCATE(key_name, json);

  IF key_index = 0 THEN
    RETURN NULL;
  END IF;

  SET start_index = key_index + key_length;

CASE
    WHEN SUBSTRING(json, start_index, 1) = '"' THEN
      SET start_index = start_index + 1;
      SET end_index = LOCATE('"', json, start_index);
ELSE
      SET end_index = LOCATE(',', json, start_index);
      IF end_index = 0 THEN
        SET end_index = LOCATE('}', json, start_index);
END IF;
END CASE;

RETURN SUBSTRING(json, start_index, end_index - start_index);
END //

DELIMITER ;


DELIMITER //

DROP FUNCTION IF EXISTS JSON_EXTRACT_ARRAY;
CREATE FUNCTION JSON_EXTRACT_ARRAY(json TEXT, key_name VARCHAR(255)) RETURNS TEXT
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

DELIMITER //
DROP FUNCTION IF EXISTS JSON_EXTRACT_OBJECT;
CREATE FUNCTION JSON_EXTRACT_OBJECT(json_string TEXT, key_name VARCHAR(255)) RETURNS TEXT
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
  WHILE nested_level >= 0 AND end_index <= CHAR_LENGTH(json_string) DO
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

DELIMITER //
DROP FUNCTION IF EXISTS GET_ARRAY_ITEM_BY_INDEX;
CREATE FUNCTION GET_ARRAY_ITEM_BY_INDEX(array_string TEXT, item_index INT) RETURNS TEXT
BEGIN
  DECLARE elem_start INT DEFAULT 1;
  DECLARE elem_end INT DEFAULT 0;
  DECLARE current_index INT DEFAULT 0;
  DECLARE result TEXT DEFAULT '';

  -- If the item_index is less than 1 or the array_string is empty, return an empty string
  IF item_index < 1 OR array_string = '[]' OR TRIM(array_string) = '' THEN
    RETURN '';
END IF;

  -- Loop until we find the start quote of the desired index
  WHILE current_index < item_index DO
    -- Find the start quote of the next element
    SET elem_start = LOCATE('"', array_string, elem_end + 1);
    -- If we can't find a new element, return an empty string
    IF elem_start = 0 THEN
      RETURN '';
END IF;

    -- Find the end quote of this element
    SET elem_end = LOCATE('"', array_string, elem_start + 1);
    -- If we can't find the end quote, return an empty string
    IF elem_end = 0 THEN
      RETURN '';
END IF;

    -- Increment the current_index
    SET current_index = current_index + 1;
END WHILE;

  -- When the loop exits, current_index should equal item_index, and elem_start/end should be the positions of the quotes
  -- Extract the element
  SET result = SUBSTRING(array_string, elem_start + 1, elem_end - elem_start - 1);

RETURN result;
END //

DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS JSON_VALUE_BY_KEY;

CREATE FUNCTION JSON_VALUE_BY_KEY(json TEXT, key_name VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
    DECLARE start_index INT;
    DECLARE end_index INT;
    DECLARE key_length INT;
    DECLARE key_index INT;
    DECLARE value_length INT;
    DECLARE extracted_value VARCHAR(255);

    -- Add the key structure to search for in the JSON string
    SET key_name = CONCAT('"', key_name, '":');
    SET key_length = CHAR_LENGTH(key_name);

    -- Locate the key within the JSON string
    SET key_index = LOCATE(key_name, json);

    -- If the key is not found, return NULL
    IF key_index = 0 THEN
        RETURN NULL;
    END IF;

    -- Set the starting index of the value
    SET start_index = key_index + key_length;

    -- Check if the value is a string (starts with a quote)
    IF SUBSTRING(json, start_index, 1) = '"' THEN
        -- Set the start index to the first character of the value (skipping the quote)
        SET start_index = start_index + 1;

        -- Find the end of the string value (the next quote)
        SET end_index = LOCATE('"', json, start_index);
        IF end_index = 0 THEN
            -- If there's no end quote, the JSON is malformed
            RETURN NULL;
        END IF;
    ELSE
        -- The value is not a string (e.g., a number, boolean, or null)
        -- Find the end of the value (either a comma or closing brace)
        SET end_index = LOCATE(',', json, start_index);
        IF end_index = 0 THEN
            SET end_index = LOCATE('}', json, start_index);
        END IF;
    END IF;

    -- Calculate the length of the extracted value
    SET value_length = end_index - start_index;

    -- Extract the value
    SET extracted_value = SUBSTRING(json, start_index, value_length);

    -- Return the extracted value without leading or trailing quotes
    RETURN TRIM(BOTH '"' FROM extracted_value);
END //

DELIMITER ;





