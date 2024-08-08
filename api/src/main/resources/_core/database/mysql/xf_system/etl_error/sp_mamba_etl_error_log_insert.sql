DROP PROCEDURE IF EXISTS sp_mamba_etl_error_log_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_error_log_insert(
    IN procedure_name VARCHAR(255),
    IN error_message VARCHAR(1000),
    IN error_code INT,
    IN sql_state VARCHAR(5)
)
BEGIN
    INSERT INTO _mamba_etl_error_log (procedure_name, error_message, error_code, sql_state)
    VALUES (procedure_name, error_message, error_code, sql_state);

END //

DELIMITER ;