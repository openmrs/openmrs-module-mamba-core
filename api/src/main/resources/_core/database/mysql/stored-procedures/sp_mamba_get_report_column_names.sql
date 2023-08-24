DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_get_report_column_names;

CREATE PROCEDURE sp_mamba_get_report_column_names(IN report_identifier VARCHAR(255))
BEGIN

    -- We could also pick the column names from the report definition table but it is in a comma-separated list (weigh both options)
    SELECT table_name
    INTO @table_name
    FROM mamba_dim_report_definition
    WHERE report_id = report_identifier;

    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @table_name;

END //

DELIMITER ;