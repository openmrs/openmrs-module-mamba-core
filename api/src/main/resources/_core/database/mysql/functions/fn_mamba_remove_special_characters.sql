DROP FUNCTION IF EXISTS fn_mamba_remove_special_characters;

DELIMITER //

CREATE FUNCTION fn_mamba_remove_special_characters(input_text VARCHAR(255))
    RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
    DECLARE modified_string VARCHAR(255);

    SET modified_string = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
    (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(input_text, '!', ''), '@', ''), '#', ''), '$', ''),
                                                             '%', ''), '^', ''), '&', ''), '*', ''), '?', ''), '/', ''),
             ',', ''), ')', ''), '(', ''), '"', ''), '-', ''), '=', ''),'+', ''),'£', ''),':', ''),';', ''),'>', ''),'<', ''),'\'', '');

RETURN modified_string;
END //

DELIMITER ;