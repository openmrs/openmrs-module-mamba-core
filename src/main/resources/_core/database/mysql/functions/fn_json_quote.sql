DELIMITER //
DROP FUNCTION IF EXISTS REMOVE_QUOTES
CREATE FUNCTION REMOVE_QUOTES(original TEXT) RETURNS TEXT
BEGIN
  DECLARE without_quotes TEXT;

  -- Replace both single and double quotes with nothing
  SET without_quotes = REPLACE(REPLACE(original, '"', ''), '''', '');

RETURN without_quotes;
END //

DELIMITER ;