-- $BEGIN

CREATE TABLE _mamba_etl_error_log
(
    id             INT          NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary Key',
    procedure_name VARCHAR(255) NOT NULL,
    error_message  VARCHAR(1000),
    error_code     INT,
    sql_state      VARCHAR(5),
    error_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
    CHARSET = UTF8MB4;

-- $END