DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule()

BEGIN

    DECLARE etl_execution_delay_seconds TINYINT(2) DEFAULT 0; -- 0 Seconds
    DECLARE interval_seconds INT;
    DECLARE start_time_seconds BIGINT;
    DECLARE end_time_seconds BIGINT;
    DECLARE time_now DATETIME;
    DECLARE txn_end_time DATETIME;
    DECLARE next_schedule_time DATETIME;
    DECLARE next_schedule_seconds BIGINT;
    DECLARE missed_schedule_seconds INT DEFAULT 0;
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

    IF etl_is_ready_to_run THEN

        SET time_now = NOW();
        SET start_time_seconds = UNIX_TIMESTAMP(time_now);

        INSERT INTO _mamba_etl_schedule(start_time, transaction_status)
        VALUES (time_now, 'RUNNING');

        SET @last_inserted_id = LAST_INSERT_ID();

        UPDATE _mamba_etl_user_settings
        SET last_etl_schedule_insert_id = @last_inserted_id
        WHERE TRUE
        ORDER BY id DESC
        LIMIT 1;

        -- Call ETL
        CALL sp_mamba_etl_scheduler_wrapper();

        SET txn_end_time = NOW();
        SET end_time_seconds = UNIX_TIMESTAMP(txn_end_time);

        SET time_taken = (end_time_seconds - start_time_seconds);


        SET interval_seconds = (SELECT etl_interval_seconds
                                FROM _mamba_etl_user_settings
                                ORDER BY id DESC
                                LIMIT 1);

        SET next_schedule_seconds = start_time_seconds + interval_seconds + etl_execution_delay_seconds;
        SET next_schedule_time = FROM_UNIXTIME(next_schedule_seconds);

        -- Run ETL immediately if schedule was missed (give allowance of 1 second)
        IF end_time_seconds > next_schedule_seconds THEN
            SET missed_schedule_seconds = end_time_seconds - next_schedule_seconds;
            SET next_schedule_time = FROM_UNIXTIME(end_time_seconds + 1);
        END IF;

        UPDATE _mamba_etl_schedule
        SET end_time                   = txn_end_time,
            next_schedule              = next_schedule_time,
            execution_duration_seconds = time_taken,
            missed_schedule_by_seconds = missed_schedule_seconds,
            completion_status          = 'SUCCESS',
            transaction_status         = 'COMPLETED'
        WHERE id = @last_inserted_id;

    END IF;

END //

DELIMITER ;



CREATE PROCEDURE sp_mamba_etl_schedule()

BEGIN
    DECLARE etl_execution_delay_seconds TINYINT(2) DEFAULT 0;
    DECLARE interval_seconds INT;
    DECLARE start_time_seconds BIGINT;
    DECLARE end_time_seconds BIGINT;
    DECLARE time_now DATETIME;
    DECLARE txn_end_time DATETIME;
    DECLARE next_schedule_time DATETIME;
    DECLARE next_schedule_seconds BIGINT;
    DECLARE missed_schedule_seconds INT DEFAULT 0;
    DECLARE time_taken BIGINT;
    DECLARE etl_is_ready_to_run BOOLEAN DEFAULT FALSE;
    DECLARE heartbeat_timeout_minutes INT DEFAULT 60; -- Set based on expected execution time
    -- 1. Check for any "RUNNING" job with an *inactive heartbeat*
    UPDATE _mamba_etl_schedule
    SET completion_status = 'FAILED', transaction_status = 'COMPLETED'
    WHERE transaction_status = 'RUNNING'
      AND TIMESTAMPDIFF(MINUTE, last_heartbeat, NOW()) > heartbeat_timeout_minutes;
    -- 2. Verify if ETL is *ready to start* (no active "RUNNING" job)
    SET etl_is_ready_to_run = (SELECT COALESCE(
                                              (SELECT IF(transaction_status = 'COMPLETED'
                                                             AND completion_status = 'SUCCESS',
                                                         TRUE, FALSE)
                                               FROM _mamba_etl_schedule
                                               ORDER BY id DESC
                                               LIMIT 1), TRUE));
    IF etl_is_ready_to_run THEN
        SET time_now = NOW();
        SET start_time_seconds = UNIX_TIMESTAMP(time_now);
        -- 3. Insert new job record (with an initial heartbeat)
        INSERT INTO _mamba_etl_schedule(start_time, transaction_status, last_heartbeat)
        VALUES (time_now, 'RUNNING', time_now);
        SET @last_inserted_id = LAST_INSERT_ID();
        -- 4. Store last inserted ETL job ID
        UPDATE _mamba_etl_user_settings
        SET last_etl_schedule_insert_id = @last_inserted_id
        WHERE TRUE
        ORDER BY id DESC
        LIMIT 1;
        -- 5. Periodically update heartbeat during execution
        -- (Modify sp_mamba_etl_scheduler_wrapper to call this)
        CREATE EVENT heartbeat_update_event
        ON SCHEDULE EVERY 5 MINUTE
        DO
        UPDATE _mamba_etl_schedule
        SET last_heartbeat = NOW()
        WHERE id = @last_inserted_id AND transaction_status = 'RUNNING';
        -- 6. Execute the ETL process
        CALL sp_mamba_etl_scheduler_wrapper();
        -- 7. Capture execution end time
        SET txn_end_time = NOW();
        SET end_time_seconds = UNIX_TIMESTAMP(txn_end_time);
        SET time_taken = (end_time_seconds - start_time_seconds);
        -- 8. Determine next schedule
        SET interval_seconds = (SELECT etl_interval_seconds
                                FROM _mamba_etl_user_settings
                                ORDER BY id DESC
                                LIMIT 1);
        SET next_schedule_seconds = start_time_seconds + interval_seconds + etl_execution_delay_seconds;
        SET next_schedule_time = FROM_UNIXTIME(next_schedule_seconds);
        -- 9. Handle missed schedules (if execution took too long)
        IF end_time_seconds > next_schedule_seconds THEN
            SET missed_schedule_seconds = end_time_seconds - next_schedule_seconds;
            SET next_schedule_time = FROM_UNIXTIME(end_time_seconds + 1);
        END IF;
        -- 10. Update the schedule table with completion details
        UPDATE _mamba_etl_schedule
        SET end_time                   = txn_end_time,
            next_schedule              = next_schedule_time,
            execution_duration_seconds = time_taken,
            missed_schedule_by_seconds = missed_schedule_seconds,
            completion_status          = 'SUCCESS',
            transaction_status         = 'COMPLETED'
        WHERE id = @last_inserted_id;
        -- 11. Remove the heartbeat event
        DROP EVENT heartbeat_update_event;
    END IF;
END;