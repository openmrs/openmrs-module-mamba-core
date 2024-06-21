DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule()
BEGIN

    DECLARE schedule_interval_seconds BIGINT DEFAULT 300; -- 5 Seconds
    DECLARE start_time_seconds BIGINT;
    DECLARE end_time_seconds BIGINT;
    DECLARE start_time DATETIME DEFAULT NOW();
    DECLARE end_time DATETIME;
    DECLARE next_schedule DATETIME;
    DECLARE missed_schedule_by_seconds BIGINT;
    DECLARE completion_status ENUM ('SUCCESS', 'ERROR');
    DECLARE txn_status ENUM ('RUNNING', 'COMPLETED') DEFAULT 'RUNNING';
    DECLARE success_or_error_message MEDIUMTEXT;
    DECLARE time_taken BIGINT;

    DECLARE last_next_schedule DATETIME;

    SET start_time = NOW();
    -- persist this before proceeding (don't run ETL if end_time is not set),
    -- OMRS scheduler should check the schedule table
    -- decouple the scheduling from the ETL process
    SET start_time_seconds = UNIX_TIMESTAMP(start_time);

    INSERT INTO _mamba_etl_schedule(start_time, transaction_status)
    VALUES (start_time, txn_status);

    CALL sp_mamba_data_processing_etl(); -- TODO: call Laureen increment script instead

    SET end_time = NOW();
    SET end_time_seconds = UNIX_TIMESTAMP(end_time);

    SET time_taken = (end_time_seconds - start_time_seconds);
    SELECT time_taken;

    -- Run ETL immediately if schedule was missed (give allowance of 1 second)
    SET next_schedule = start_time + schedule_interval_seconds;
    IF NOW() > next_schedule THEN
        SET next_schedule = NOW() + 1;
    END IF;

    SET last_next_schedule = (SELECT MAX(next_schedule) FROM _mamba_etl_schedule);

    IF last_next_schedule IS NULL THEN
        SET missed_schedule_by_seconds = 0;
    ELSE
        SET missed_schedule_by_seconds = (start_time_seconds - UNIX_TIMESTAMP(last_next_schedule));
    END IF;

    INSERT INTO _mamba_etl_schedule(schedule_interval_seconds,
                                    end_time,
                                    next_schedule,
                                    execution_duration_seconds,
                                    missed_schedule_by_seconds,
                                    completion_status,
                                    transaction_status,
                                    success_or_error_message)
    VALUES (schedule_interval_seconds,
            end_time,
            next_schedule,
            time_taken,
            missed_schedule_by_seconds,
            completion_status,
            'COMPLETED',
            success_or_error_message);

END //

DELIMITER ;