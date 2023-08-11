DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_get_report_column_names;

CREATE PROCEDURE sp_mamba_get_report_column_names(IN report_identifier VARCHAR(255))
BEGIN

    SELECT table_name
    INTO @table_name
    FROM mamba_dim_report_definition
    WHERE TABLE_NAME = report_identifier;

    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @table_name;

END //

DELIMITER ;