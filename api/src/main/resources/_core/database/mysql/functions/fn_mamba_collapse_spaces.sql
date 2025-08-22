DROP FUNCTION IF EXISTS fn_mamba_collapse_spaces;

DELIMITER //

CREATE FUNCTION fn_mamba_collapse_spaces(input_text TEXT)
 RETURNS TEXT
 DETERMINISTIC
BEGIN
 DECLARE result TEXT;
 
 IF input_text IS NULL THEN
  RETURN NULL;
 END IF;
 
 SET result = input_text;
 
 -- Replace tabs and other whitespace characters with spaces
 SET result = REPLACE(result, '\t', ' ');
 SET result = REPLACE(result, '\n', ' ');
 SET result = REPLACE(result, '\r', ' ');
 
 -- Replace multiple spaces with single space efficiently
 -- This approach avoids WHILE loops by doing fixed replacements
 SET result = REPLACE(result, '          ', ' '); -- 10 spaces
 SET result = REPLACE(result, '     ', ' ');      -- 5 spaces  
 SET result = REPLACE(result, '    ', ' ');       -- 4 spaces
 SET result = REPLACE(result, '   ', ' ');        -- 3 spaces
 SET result = REPLACE(result, '  ', ' ');         -- 2 spaces
 SET result = REPLACE(result, '  ', ' ');         -- Run again to handle odd patterns
 
 RETURN TRIM(result);

END //

DELIMITER ;