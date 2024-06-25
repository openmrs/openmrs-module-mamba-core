DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule(
    IN etl_stored_procedure_to_run VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    DECLARE interval_seconds BIGINT DEFAULT 300; -- 5 Seconds
    DECLARE start_time_seconds BIGINT;
    DECLARE end_time_seconds BIGINT;
    DECLARE start_time DATETIME DEFAULT NOW();
    DECLARE txn_end_time DATETIME;
    DECLARE next_schedule DATETIME;
    DECLARE missed_schedule_by_seconds BIGINT;
    DECLARE completion_status ENUM ('SUCCESS', 'ERROR');
    DECLARE txn_status ENUM ('RUNNING', 'COMPLETED');
    DECLARE success_or_error_message MEDIUMTEXT;
    DECLARE time_taken BIGINT;

    DECLARE last_next_schedule DATETIME;
    DECLARE etl_is_ready_to_run BOOLEAN DEFAULT FALSE;

    -- check if _mamba_etl_schedule is empty(new) or last transaction_status is 'COMPLETED' and its 'end_time' is set.
    SET etl_is_ready_to_run = (SELECT COALESCE(
                                              (SELECT IF(end_time IS NOT NULL AND transaction_status = 'COMPLETED',
                                                         TRUE, FALSE)
                                               FROM _mamba_etl_schedule
                                               ORDER BY id DESC
                                               LIMIT 1), TRUE));

    IF etl_is_ready_to_run THEN

        SET start_time = NOW();
        SET start_time_seconds = UNIX_TIMESTAMP(start_time);

        INSERT INTO _mamba_etl_schedule(start_time, transaction_status)
        VALUES (start_time, 'RUNNING');

        SET @last_inserted_id = LAST_INSERT_ID();

        SET @procedure_call = CONCAT('CALL ', etl_stored_procedure_to_run, '();');
        PREPARE stmt FROM @procedure_call;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET txn_end_time = NOW();
        SET end_time_seconds = UNIX_TIMESTAMP(txn_end_time);

        SET time_taken = (end_time_seconds - start_time_seconds);
        SELECT time_taken;

        -- Run ETL immediately if schedule was missed (give allowance of 5 seconds)
        SET next_schedule = start_time + interval_seconds;
        IF NOW() > next_schedule THEN
            SET next_schedule = NOW() + 1;
        END IF;

        SET last_next_schedule = (SELECT MAX(next_schedule) FROM _mamba_etl_schedule);

        IF last_next_schedule IS NULL THEN
            SET missed_schedule_by_seconds = 0;
        ELSE
            SET missed_schedule_by_seconds = (start_time_seconds - UNIX_TIMESTAMP(last_next_schedule));
        END IF;

        UPDATE _mamba_etl_schedule
        SET schedule_interval_seconds  = interval_seconds,
            end_time                   = txn_end_time,
            next_schedule              = next_schedule,
            execution_duration_seconds = time_taken,
            missed_schedule_by_seconds = missed_schedule_by_seconds,
            completion_status          = 'SUCCESS',
            transaction_status         = 'COMPLETED'
        WHERE id = @last_inserted_id;

    END IF;

END //

DELIMITER ;