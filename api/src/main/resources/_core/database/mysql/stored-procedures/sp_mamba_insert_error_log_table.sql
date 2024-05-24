DROP PROCEDURE IF EXISTS sp_mamba_insert_error_log_table;

DELIMITER //

CREATE PROCEDURE sp_mamba_insert_error_log_table(
    IN procedure_name VARCHAR(255),
    IN error_message VARCHAR(1000),
    IN error_code INT,
    IN sql_state VARCHAR(5)
)
BEGIN
    INSERT INTO mamba_error_log (procedure_name, error_message, error_code, sql_state)
    VALUES (error_message, procedure_name, error_code, sql_state);

END //

DELIMITER ;
