DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule(
    IN etl_stored_procedure_to_run VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    DECLARE etl_execution_delay_seconds TINYINT(2) DEFAULT 0; -- 0 Seconds
    DECLARE etl_interval_seconds INT;
    DECLARE start_time_seconds BIGINT;
    DECLARE end_time_seconds BIGINT;
    DECLARE start_time DATETIME DEFAULT NOW();
    DECLARE txn_end_time DATETIME;
    DECLARE next_schedule DATETIME;
    DECLARE next_schedule_seconds BIGINT;
    DECLARE missed_schedule_by_seconds INT DEFAULT 0;
    DECLARE completion_status ENUM ('SUCCESS', 'ERROR');
    DECLARE time_taken BIGINT;
    DECLARE etl_is_ready_to_run BOOLEAN DEFAULT FALSE;

    -- check if _mamba_etl_schedule is empty(new) or last transaction_status
    -- is 'COMPLETED' AND it was a 'SUCCESS' AND its 'end_time' was set.
    SET etl_is_ready_to_run = (SELECT COALESCE(
                                              (SELECT IF(end_time IS NOT NULL
                                                             AND transaction_status = 'COMPLETED'
                                                             AND completion_status = 'SUCCESS',
                                                         TRUE, FALSE)
                                               FROM _mamba_etl_schedule
                                               ORDER BY id DESC
                                               LIMIT 1), TRUE));

    SET etl_interval_seconds = (SELECT etl_interval_seconds
                                FROM _mamba_etl_user_settings
                                ORDER BY id DESC
                                LIMIT 1);

    IF etl_is_ready_to_run THEN

        SET start_time = NOW();
        SET start_time_seconds = UNIX_TIMESTAMP(start_time);

        INSERT INTO _mamba_etl_schedule(start_time, transaction_status)
        VALUES (start_time, 'RUNNING');

        SET @last_inserted_id = LAST_INSERT_ID();

        UPDATE _mamba_etl_user_settings
        SET last_etl_schedule_insert_id = @last_inserted_id
        WHERE TRUE
        ORDER BY id DESC
        LIMIT 1;

        SET @procedure_call = CONCAT('CALL ', etl_stored_procedure_to_run, '();');
        PREPARE stmt FROM @procedure_call;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET txn_end_time = NOW();
        SET end_time_seconds = UNIX_TIMESTAMP(txn_end_time);

        SET time_taken = (end_time_seconds - start_time_seconds);
        SELECT time_taken;

        SET next_schedule_seconds = start_time_seconds + etl_interval_seconds + etl_execution_delay_seconds;
        SET next_schedule = FROM_UNIXTIME(next_schedule_seconds);

        -- Run ETL immediately if schedule was missed (give allowance of 1 second)
        IF end_time_seconds > next_schedule_seconds THEN
            SET missed_schedule_by_seconds = end_time_seconds - next_schedule_seconds;
            SET next_schedule = FROM_UNIXTIME(end_time_seconds + 1);
        END IF;

        UPDATE _mamba_etl_schedule
        SET end_time                   = txn_end_time,
            next_schedule              = next_schedule,
            execution_duration_seconds = time_taken,
            missed_schedule_by_seconds = missed_schedule_by_seconds,
            completion_status          = 'SUCCESS',
            transaction_status         = 'COMPLETED'
        WHERE id = @last_inserted_id;

    END IF;

END //

DELIMITER ;