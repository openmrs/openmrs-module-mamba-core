DELIMITER //

DROP FUNCTION IF EXISTS fn_get_obs_value_column;

CREATE FUNCTION fn_get_obs_value_column(conceptDatatype CHAR(20) CHARACTER SET UTF8MB4) RETURNS CHAR(20) CHARACTER SET UTF8MB4
    DETERMINISTIC
BEGIN
    DECLARE obsValueColumn VARCHAR(20) CHARACTER SET UTF8MB4;

    IF (conceptDatatype = 'Text' OR conceptDatatype = 'Coded' OR conceptDatatype = 'N/A' OR
        conceptDatatype = 'Boolean') THEN
        SET obsValueColumn = 'obs_value_text';
    ELSEIF conceptDatatype = 'Date' OR conceptDatatype = 'Datetime' THEN
        SET obsValueColumn = 'obs_value_datetime';
    ELSEIF conceptDatatype = 'Numeric' THEN
        SET obsValueColumn = 'obs_value_numeric';
    END IF;

    RETURN (obsValueColumn);
END//

DELIMITER ;


