DROP PROCEDURE IF EXISTS sp_mamba_etl_un_stuck_scheduler;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_un_stuck_scheduler()
BEGIN

    DECLARE running_schedule_record BOOLEAN DEFAULT FALSE;
    DECLARE no_running_mamba_sp BOOLEAN DEFAULT FALSE;
    DECLARE last_schedule_record_id INT;

    SET running_schedule_record = (SELECT COALESCE(
                                                  (SELECT IF(transaction_status = 'RUNNING'
                                                                 AND completion_status is null,
                                                             TRUE, FALSE)
                                                   FROM _mamba_etl_schedule
                                                   ORDER BY id DESC
                                                   LIMIT 1), TRUE));
    SET no_running_mamba_sp = NOT EXISTS (SELECT 1
                                          FROM performance_schema.events_statements_current
                                          WHERE SQL_TEXT LIKE 'CALL sp_mamba_etl_scheduler_wrapper(%'
                                             OR SQL_TEXT = 'CALL sp_mamba_etl_scheduler_wrapper()');
    IF running_schedule_record AND no_running_mamba_sp THEN
        SET last_schedule_record_id = (SELECT MAX(id) FROM _mamba_etl_schedule limit 1);
        UPDATE _mamba_etl_schedule
        SET end_time                   = NOW(),
            completion_status          = 'SUCCESS',
            transaction_status         = 'COMPLETED',
            success_or_error_message   = 'Stuck schedule updated'
            WHERE id = last_schedule_record_id;
    END IF;

END //

DELIMITER ;
