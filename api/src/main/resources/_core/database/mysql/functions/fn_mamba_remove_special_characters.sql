DROP FUNCTION IF EXISTS fn_mamba_remove_special_characters;

DELIMITER //

CREATE FUNCTION fn_mamba_remove_special_characters(input_text VARCHAR(255))
    RETURNS VARCHAR(255)
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Removes special characters from input text'
BEGIN
    DECLARE modified_string VARCHAR(255);
    DECLARE special_chars VARCHAR(255);
    DECLARE char_index INT DEFAULT 1;
    DECLARE current_char CHAR(1);
    DECLARE mysql_version VARCHAR(20);
    
    -- Get MySQL version
    SET mysql_version = SUBSTRING_INDEX(VERSION(), '.', 1);
    
    IF input_text IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Use REGEXP_REPLACE for MySQL 8.0+
    IF CAST(mysql_version AS UNSIGNED) >= 8 THEN
        RETURN TRIM(REGEXP_REPLACE(input_text, '[^a-zA-Z0-9 ]', ''));
    ELSE
        -- Fallback for MySQL 5.7 and earlier
        SET modified_string = input_text;
        
        -- Define special characters to remove
        SET special_chars = '!@#$%^&*?/,()"-=+£:;><ã\\|[]{}\'~`.';
        
        -- Remove each special character
        WHILE char_index <= CHAR_LENGTH(special_chars) DO
            SET current_char = SUBSTRING(special_chars, char_index, 1);
            SET modified_string = REPLACE(modified_string, current_char, '');
            SET char_index = char_index + 1;
        END WHILE;
        
        -- Trim any leading or trailing spaces
        RETURN TRIM(modified_string);
    END IF;
END //

DELIMITER ;