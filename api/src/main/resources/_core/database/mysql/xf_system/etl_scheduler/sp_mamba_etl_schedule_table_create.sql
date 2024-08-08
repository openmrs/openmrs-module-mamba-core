DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule_table_create;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule_table_create()
BEGIN

    CREATE TABLE IF NOT EXISTS _mamba_etl_schedule
    (
        id                         INT      NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
        start_time                 DATETIME NOT NULL DEFAULT NOW(),
        end_time                   DATETIME,
        next_schedule              DATETIME,
        execution_duration_seconds BIGINT,
        missed_schedule_by_seconds BIGINT,
        completion_status          ENUM ('SUCCESS', 'ERROR'),
        transaction_status         ENUM ('RUNNING', 'COMPLETED'),
        success_or_error_message   MEDIUMTEXT,

        INDEX mamba_idx_start_time (start_time),
        INDEX mamba_idx_end_time (end_time),
        INDEX mamba_idx_transaction_status (transaction_status),
        INDEX mamba_idx_completion_status (completion_status)
    )
        CHARSET = UTF8MB4;

END //

DELIMITER ;

