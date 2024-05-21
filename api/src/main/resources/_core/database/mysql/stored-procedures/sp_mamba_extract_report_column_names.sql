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

        -- Fetch the parameters for the procedure and provide empty string values for each
        SET @params := NULL;

        SELECT GROUP_CONCAT('\'\'' SEPARATOR ', ')
        INTO @params
        FROM mamba_dim_report_definition_parameters rdp
                 INNER JOIN mamba_dim_report_definition rd on rdp.report_id = rd.report_id
        WHERE rd.report_columns_procedure_name = proc_name;

        IF @params IS NULL THEN
            SET @procedure_call = CONCAT('CALL ', proc_name, '();');
        ELSE
            SET @procedure_call = CONCAT('CALL ', proc_name, '(', @params, ');');
        END IF;

        PREPARE stmt FROM @procedure_call;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;