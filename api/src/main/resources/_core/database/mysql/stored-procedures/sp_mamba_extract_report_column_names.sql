DROP PROCEDURE IF EXISTS sp_mamba_extract_report_column_names;

DELIMITER //

CREATE PROCEDURE sp_mamba_extract_report_column_names()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE proc_name VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT DISTINCT report_columns_procedure_name FROM mamba_dim_report_definition;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO proc_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Output the value of proc_name
        SELECT proc_name as procedure_name;

        -- Fetch the parameters for the procedure and provide empty string values for each
        SET @params := NULL;
        SELECT GROUP_CONCAT('\'\'' SEPARATOR ', ')
        INTO @params
        FROM mamba_dim_report_definition_parameters rdp
                 INNER JOIN mamba_dim_report_definition rd on rdp.report_id = rd.report_id
        WHERE rd.report_columns_procedure_name = proc_name;

        -- Output the value of @params
        SELECT @params as parameters;

        IF @params IS NULL THEN
            SELECT @s as is_null_here;
            SET @s = CONCAT('CALL ', proc_name, '();');
        ELSE
            SET @s = CONCAT('CALL ', proc_name, '(', @params, ');');
            SELECT @s as is_not_null_here;
        END IF;

        -- Output the value of @s
        SELECT @s as procedure_call;

        PREPARE stmt FROM @s;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;