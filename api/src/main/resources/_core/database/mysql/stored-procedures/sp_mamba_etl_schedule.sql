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
    DECLARE completion_status ENUM ('SUCCESS', 'ERROR') DEFAULT 'SUCCESS';
    DECLARE success_or_error_message MEDIUMTEXT;
    DECLARE time_taken BIGINT;

    DECLARE last_next_schedule DATETIME;

    SET start_time = NOW();
    SET start_time_seconds = UNIX_TIMESTAMP(start_time);

    CALL sp_mamba_data_processing_etl();

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
                                    start_time,
                                    end_time,
                                    next_schedule,
                                    execution_duration_seconds,
                                    missed_schedule_by_seconds,
                                    completion_status,
                                    success_or_error_message)
    VALUES (schedule_interval_seconds,
            start_time,
            end_time,
            next_schedule,
            time_taken,
            missed_schedule_by_seconds,
            completion_status,
            success_or_error_message);

    -- Create a one-time event to run at next_schedule
    -- MySQL will automatically drop this event immediately after it has executed
    SET @event_name = CONCAT('_mamba_etl_schedule_event_', UNIX_TIMESTAMP(next_schedule));
    SET @create_event_sql = CONCAT('CREATE EVENT ', @event_name, ' ON SCHEDULE AT ''', next_schedule,
                                   ''' DO CALL sp_mamba_etl_schedule();');
    PREPARE stmt FROM @create_event_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;