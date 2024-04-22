DROP FUNCTION IF EXISTS fn_mamba_array_length;
DELIMITER //

CREATE FUNCTION fn_mamba_array_length(array_string TEXT) RETURNS INT
    DETERMINISTIC
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