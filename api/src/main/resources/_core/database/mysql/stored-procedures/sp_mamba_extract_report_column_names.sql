DROP PROCEDURE IF EXISTS sp_mamba_extract_report_column_names;

DELIMITER //

CREATE PROCEDURE sp_mamba_extract_report_column_names()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE proc_name VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT DISTINCT report_columns_procedure_name FROM mamba_dim_report_definition;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur;

read_loop: LOOP
        FETCH cur INTO proc_name;
        IF done THEN
            LEAVE read_loop;
END IF;

        -- Fetch the parameters for the procedure
        SET @params = NULL;
SELECT GROUP_CONCAT(parameter_name SEPARATOR ', ') INTO @params
FROM mamba_dim_report_definition_parameters
WHERE report_columns_procedure_name = proc_name;

-- If there are no parameters, call the procedure without parameters
IF @params IS NULL THEN
            SET @s = CONCAT('CALL ', proc_name, '()');
ELSE
            SET @s = CONCAT('CALL ', proc_name, '(', @params, ')');
END IF;

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END LOOP;

CLOSE cur;
END //

DELIMITER ;