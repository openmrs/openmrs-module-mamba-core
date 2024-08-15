DROP FUNCTION IF EXISTS fn_mamba_json_length;
DELIMITER //

CREATE FUNCTION fn_mamba_json_length(json_array TEXT) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE element_count INT DEFAULT 0;
    DECLARE current_position INT DEFAULT 1;

    WHILE current_position <= CHAR_LENGTH(json_array) DO
        SET element_count = element_count + 1;
        SET current_position = LOCATE(',', json_array, current_position) + 1;

        IF current_position = 0 THEN
            RETURN element_count;
        END IF;
    END WHILE;

RETURN element_count;
END //

DELIMITER ;