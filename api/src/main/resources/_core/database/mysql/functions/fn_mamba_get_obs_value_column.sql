DROP FUNCTION IF EXISTS fn_mamba_get_obs_value_column;

DELIMITER //

CREATE FUNCTION fn_mamba_get_obs_value_column(conceptDatatype VARCHAR(20)) RETURNS VARCHAR(20)
    DETERMINISTIC
BEGIN
    DECLARE obsValueColumn VARCHAR(20);

    CASE
        WHEN conceptDatatype IN ('Text','Coded','N/A','Boolean') THEN obsValueColumn = 'obs_value_text';
        WHEN conceptDatatype IN ('Date','Datetime') THEN obsValueColumn = 'obs_value_datetime';
        WHEN conceptDatatype  = 'Numeric' THEN obsValueColumn = 'obs_value_numeric';
    END CASE;

    RETURN obsValueColumn;
END //

DELIMITER ;