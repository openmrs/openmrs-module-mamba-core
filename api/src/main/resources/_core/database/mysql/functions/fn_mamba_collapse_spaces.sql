DROP FUNCTION IF EXISTS fn_mamba_collapse_spaces;

DELIMITER //

CREATE FUNCTION fn_mamba_collapse_spaces(input_text TEXT)
    RETURNS TEXT
    DETERMINISTIC
BEGIN
    DECLARE result TEXT;
    SET result = input_text;

    -- Loop to collapse multiple spaces into one
    WHILE INSTR(result, '  ') > 0
        DO
            SET result = REPLACE(result, '  ', ' '); -- Replace two spaces with one space
        END WHILE;

    RETURN result;

END //

DELIMITER ;