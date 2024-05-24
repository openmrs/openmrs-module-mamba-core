DROP PROCEDURE IF EXISTS sp_mamba_create_error_log_table;

DELIMITER //

CREATE PROCEDURE sp_mamba_create_error_log_table()
BEGIN
    CREATE TABLE mamba_error_log
    (
        id             INT          NOT NULL AUTO_INCREMENT,
        procedure_name VARCHAR(255) NOT NULL,
        error_message  VARCHAR(1000),
        error_code     INT,
        sql_state      VARCHAR(5),
        error_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

        PRIMARY KEY (id)
    )
        CHARSET = UTF8MB4;

END //

DELIMITER ;