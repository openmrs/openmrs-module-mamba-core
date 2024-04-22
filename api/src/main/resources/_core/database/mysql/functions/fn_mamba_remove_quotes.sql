DROP FUNCTION IF EXISTS fn_mamba_remove_quotes;
DELIMITER //

CREATE FUNCTION fn_mamba_remove_quotes(original TEXT) RETURNS TEXT
    DETERMINISTIC
BEGIN
  DECLARE without_quotes TEXT;

  -- Replace both single and double quotes with nothing
  SET without_quotes = REPLACE(REPLACE(original, '"', ''), '''', '');

RETURN fn_mamba_remove_all_whitespace(without_quotes);
END //

DELIMITER ;