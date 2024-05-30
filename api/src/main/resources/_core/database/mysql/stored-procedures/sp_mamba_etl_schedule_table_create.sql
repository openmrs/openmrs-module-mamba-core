DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule_table_create;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule_table_create()
BEGIN

    CREATE TABLE IF NOT EXISTS students
    (
        id                            INT      NOT NULL AUTO_INCREMENT,
        start_time                    DATETIME NOT NULL,
        end_time                      DATETIME NOT NULL,
        next_scheduled_time           DATETIME NOT NULL,
        execution_duration_in_seconds BIGINT   NOT NULL,
        scheduled_interval_in_seconds BIGINT   NOT NULL,
        completion_status             CHAR(10),
        success_or_error_message      VARCHAR(255),

        PRIMARY KEY (id)
    )
        CHARSET = UTF8MB4;

END //

DELIMITER ;