DELIMITER //
DROP FUNCTION IF EXISTS REMOVE_ALL_WHITESPACE;
CREATE FUNCTION REMOVE_ALL_WHITESPACE(input_string TEXT) RETURNS TEXT
BEGIN
  DECLARE cleaned_string TEXT;
  SET cleaned_string = input_string;

  -- Replace common whitespace characters
  SET cleaned_string = REPLACE(cleaned_string, CHAR(9), '');   -- Horizontal tab
  SET cleaned_string = REPLACE(cleaned_string, CHAR(10), '');  -- Line feed
  SET cleaned_string = REPLACE(cleaned_string, CHAR(13), '');  -- Carriage return
  SET cleaned_string = REPLACE(cleaned_string, CHAR(32), '');  -- Space
  SET cleaned_string = REPLACE(cleaned_string, CHAR(160), ''); -- Non-breaking space

RETURN TRIM(cleaned_string);
END //

DELIMITER ;


DELIMITER //
DROP FUNCTION IF EXISTS REMOVE_QUOTES;
CREATE FUNCTION REMOVE_QUOTES(original TEXT) RETURNS TEXT
BEGIN
  DECLARE without_quotes TEXT;

  -- Replace both single and double quotes with nothing
  SET without_quotes = REPLACE(REPLACE(original, '"', ''), '''', '');

RETURN REMOVE_ALL_WHITESPACE(without_quotes);
END //

DELIMITER ;