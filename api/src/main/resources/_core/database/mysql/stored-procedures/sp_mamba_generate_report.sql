DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_generate_report;

CREATE PROCEDURE sp_mamba_generate_report(
    IN report_id VARCHAR(255)
)
BEGIN

    SET @report_identifier = report_id;

    SELECT DISTINCT report_procedure_name
    INTO @procedure_name
    FROM mamba_dim_report_metadata
    WHERE report_id = @report_identifier;

    SET @compute_obs_procedure_sql = CONCAT('CALL ', @procedure_name, '();');

    PREPARE prepared_statement FROM @compute_obs_procedure_sql;
    EXECUTE prepared_statement;
    DEALLOCATE PREPARE prepared_statement;
END;
//

DELIMITER ;