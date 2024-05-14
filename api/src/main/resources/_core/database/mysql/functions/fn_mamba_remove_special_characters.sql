DROP FUNCTION IF EXISTS fn_mamba_remove_special_characters;

DELIMITER //

CREATE FUNCTION fn_mamba_remove_special_characters(input_text VARCHAR(255))
    RETURNS VARCHAR(255) deterministic
BEGIN
    DECLARE output_text VARCHAR(255);
    DECLARE i INT DEFAULT 1;
    DECLARE current_char CHAR;

    SET output_text = '';

    -- Loop through each character in the input text
    WHILE i <= LENGTH(input_text) DO
        SET current_char = SUBSTRING(input_text, i, 1);

        -- Check if the current character is alphanumeric
        IF current_char REGEXP '[[:alnum:]]' THEN
            SET output_text = CONCAT(output_text, current_char);
END IF;

        SET i = i + 1;
END WHILE;

RETURN output_text;
END//

DELIMITER ;