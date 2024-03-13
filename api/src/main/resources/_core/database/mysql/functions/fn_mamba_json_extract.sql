DROP FUNCTION IF EXISTS fn_mamba_json_extract;
DELIMITER //

CREATE FUNCTION fn_mamba_json_extract(json TEXT, key_name VARCHAR(255)) RETURNS VARCHAR(255)
    DETERMINISTIC
BEGIN
  DECLARE start_index INT;
  DECLARE end_index INT;
  DECLARE key_length INT;
  DECLARE key_index INT;

  SET key_name = CONCAT( key_name, '":');
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