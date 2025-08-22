DROP FUNCTION IF EXISTS fn_mamba_remove_special_characters;

DELIMITER //

CREATE FUNCTION fn_mamba_remove_special_characters(input_text VARCHAR(255))
 RETURNS VARCHAR(255)
 DETERMINISTIC
 NO SQL
 COMMENT 'Removes special characters from input text'
BEGIN
 DECLARE result VARCHAR(255);

 IF input_text IS NULL THEN
  RETURN NULL;
 END IF;

 SET result = input_text;

 -- Remove special characters using nested REPLACE for better performance
 -- This avoids the WHILE loop and is much more efficient
 SET result = REPLACE(result, '!', '');
 SET result = REPLACE(result, '@', '');
 SET result = REPLACE(result, '#', '');
 SET result = REPLACE(result, '$', '');
 SET result = REPLACE(result, '%', '');
 SET result = REPLACE(result, '^', '');
 SET result = REPLACE(result, '&', '');
 SET result = REPLACE(result, '*', '');
 SET result = REPLACE(result, '?', '');
 SET result = REPLACE(result, '/', '');
 SET result = REPLACE(result, ',', '');
 SET result = REPLACE(result, '(', '');
 SET result = REPLACE(result, ')', '');
 SET result = REPLACE(result, '"', '');
 SET result = REPLACE(result, '-', '');
 SET result = REPLACE(result, '=', '');
 SET result = REPLACE(result, '+', '');
 SET result = REPLACE(result, '£', '');
 SET result = REPLACE(result, ':', '');
 SET result = REPLACE(result, ';', '');
 SET result = REPLACE(result, '>', '');
 SET result = REPLACE(result, '<', '');
 SET result = REPLACE(result, 'ã', '');
 SET result = REPLACE(result, '\\', '');
 SET result = REPLACE(result, '|', '');
 SET result = REPLACE(result, '[', '');
 SET result = REPLACE(result, ']', '');
 SET result = REPLACE(result, '{', '');
 SET result = REPLACE(result, '}', '');
 SET result = REPLACE(result, '''', '');
 SET result = REPLACE(result, '~', '');
 SET result = REPLACE(result, '`', '');
 SET result = REPLACE(result, '.', ''); -- TODO: Remove after adding backtick support

 -- Trim any leading or trailing spaces
 RETURN TRIM(result);
END //

DELIMITER ;