DROP FUNCTION IF EXISTS fn_mamba_remove_quotes;

DELIMITER //

CREATE FUNCTION fn_mamba_remove_quotes(original TEXT)
    RETURNS TEXT
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Removes quotes from input text'

BEGIN
    DECLARE without_quotes TEXT;

    IF original IS NULL THEN
        RETURN NULL;
    END IF;

    -- Use REGEXP_REPLACE for MySQL 8.0+
    IF fn_mamba_is_mysql8_or_higher() THEN
        -- Remove single and double quotes using regex
        SET without_quotes = REGEXP_REPLACE(original, '[\'"]', '');
    ELSE
        -- Replace both single and double quotes with nothing for older MySQL versions
        SET without_quotes = REPLACE(REPLACE(original, '"', ''), '''', '');
    END IF;

    RETURN fn_mamba_remove_all_whitespace(without_quotes);
END //

DELIMITER ;