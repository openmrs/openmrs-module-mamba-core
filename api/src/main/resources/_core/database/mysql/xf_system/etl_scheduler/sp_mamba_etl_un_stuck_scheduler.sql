DROP PROCEDURE IF EXISTS sp_mamba_etl_un_stuck_scheduler;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_un_stuck_scheduler()
BEGIN

    DECLARE running_schedule_record BOOLEAN DEFAULT FALSE;
    DECLARE no_running_mamba_sp BOOLEAN DEFAULT FALSE;
    DECLARE last_schedule_record_id INT;
    DECLARE incremental_start_time DATETIME DEFAULT NOW();
    DECLARE error_schedule BOOLEAN DEFAULT FALSE;

    SET last_schedule_record_id = (SELECT MAX(id) FROM _mamba_etl_schedule limit 1);
    SET running_schedule_record = (SELECT COALESCE(
                                                  (SELECT IF(transaction_status = 'RUNNING'
                                                                 AND completion_status is null,
                                                             TRUE, FALSE)
                                                   FROM _mamba_etl_schedule
                                                   WHERE id = last_schedule_record_id), FALSE));
    SET error_schedule = (SELECT COALESCE(
                                         (SELECT IF(transaction_status = 'COMPLETED'
                                                        AND completion_status = 'ERROR',
                                                    TRUE, FALSE)
                                          FROM _mamba_etl_schedule
                                          WHERE id = last_schedule_record_id), FALSE));
    SET no_running_mamba_sp = NOT EXISTS (SELECT 1
                                          FROM performance_schema.events_statements_current
                                          WHERE SQL_TEXT LIKE 'CALL sp_mamba_etl_scheduler_wrapper(%'
                                             OR SQL_TEXT = 'CALL sp_mamba_etl_scheduler_wrapper()');
    SET incremental_start_time = COALESCE((SELECT start_time
                                           FROM _mamba_etl_schedule sch
                                           WHERE start_time IS NOT NULL
                                             AND transaction_status = 'COMPLETED'
                                             AND completion_status = 'SUCCESS'
                                             AND success_or_error_message is null
                                           ORDER BY id DESC
                                           LIMIT 1),incremental_start_time);

    IF running_schedule_record AND no_running_mamba_sp AND NOT error_schedule THEN
        UPDATE _mamba_etl_schedule
        SET end_time                 = incremental_start_time,
            start_time               = incremental_start_time,
            completion_status        = 'SUCCESS',
            transaction_status       = 'COMPLETED',
            success_or_error_message = 'Stuck schedule updated'
        WHERE id = last_schedule_record_id;
    ELSEIF error_schedule THEN
        UPDATE _mamba_etl_schedule
        SET end_time                 = incremental_start_time,
            start_time               = incremental_start_time,
            completion_status        = 'SUCCESS',
            transaction_status       = 'COMPLETED',
            success_or_error_message = 'Error schedule updated'
        WHERE id = last_schedule_record_id;
    END IF;

END //

DELIMITER ;