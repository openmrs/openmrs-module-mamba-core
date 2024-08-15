DROP FUNCTION IF EXISTS fn_mamba_remove_special_characters;

DELIMITER //

CREATE FUNCTION fn_mamba_remove_special_characters(input_text VARCHAR(255))
    RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
    DECLARE modified_string VARCHAR(255);
    DECLARE special_chars VARCHAR(255);
    DECLARE char_index INT DEFAULT 1;
    DECLARE current_char CHAR(1);

    SET modified_string = input_text;
    -- SET special_chars = '!@#$%^&*?/,()"-=+£:;><ã';
    SET special_chars = '!@#$%^&*?/,()"-=+£:;><ã\|[]{}\'~`.'; -- TODO: Added '.' xter as well but Remove after adding backtick support

    WHILE char_index <= CHAR_LENGTH(special_chars) DO
            SET current_char = SUBSTRING(special_chars, char_index, 1);
            SET modified_string = REPLACE(modified_string, current_char, '');
            SET char_index = char_index + 1;
        END WHILE;

    RETURN modified_string;
END //

DELIMITER ;