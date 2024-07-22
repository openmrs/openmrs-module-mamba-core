DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule_table_create;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule_table_create()
BEGIN

    CREATE TABLE IF NOT EXISTS _mamba_etl_schedule
    (
        id                         INT      NOT NULL AUTO_INCREMENT,
        schedule_interval_seconds  BIGINT   NOT NULL DEFAULT 300, -- 5 Seconds
        start_time                 DATETIME NOT NULL DEFAULT NOW(),
        end_time                   DATETIME,
        next_schedule              DATETIME,
        execution_duration_seconds BIGINT,
        missed_schedule_by_seconds BIGINT,
        completion_status          ENUM ('SUCCESS', 'ERROR'),
        transaction_status         ENUM ('RUNNING', 'COMPLETED'),
        success_or_error_message   MEDIUMTEXT,

        PRIMARY KEY (id)
    )
        CHARSET = UTF8MB4;

    CREATE INDEX mamba_etl_schedule_end_time_index
        ON _mamba_etl_schedule (end_time);

    CREATE INDEX mamba_etl_schedule_transaction_status_index
        ON _mamba_etl_schedule (transaction_status);

    CREATE INDEX mamba_etl_schedule_start_time_index
        ON _mamba_etl_schedule (start_time);

END //

DELIMITER ;

