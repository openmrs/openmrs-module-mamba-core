DROP FUNCTION IF EXISTS fn_mamba_remove_all_whitespace;

DELIMITER //

CREATE FUNCTION fn_mamba_remove_all_whitespace(input_string TEXT)
    RETURNS TEXT
    DETERMINISTIC
    COMMENT 'Removes all whitespace characters from input text'

BEGIN
    DECLARE cleaned_string TEXT;

    -- Handle NULL input
    IF input_string IS NULL THEN
        RETURN NULL;
    END IF;

    -- Use REGEXP_REPLACE for MySQL 8.0+
    IF fn_mamba_is_mysql8_or_higher() THEN
        -- Remove all whitespace characters using regex
        RETURN REGEXP_REPLACE(input_string, '\\s', '');
    ELSE
        -- Fallback for MySQL 5.7 and earlier
        SET cleaned_string = input_string;

        -- Replace common whitespace characters
        SET cleaned_string = REPLACE(cleaned_string, CHAR(9), ''); -- Horizontal tab
        SET cleaned_string = REPLACE(cleaned_string, CHAR(10), ''); -- Line feed
        SET cleaned_string = REPLACE(cleaned_string, CHAR(13), ''); -- Carriage return
        SET cleaned_string = REPLACE(cleaned_string, CHAR(32), ''); -- Space
        SET cleaned_string = REPLACE(cleaned_string, CHAR(160), ''); -- Non-breaking space

        RETURN cleaned_string;
    END IF;
END //

DELIMITER ;