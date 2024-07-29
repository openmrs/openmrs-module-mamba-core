DROP PROCEDURE IF EXISTS sp_mamba_etl_scheduler_wrapper;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_scheduler_wrapper()

BEGIN

    DECLARE etl_ever_scheduled TINYINT(1);
    DECLARE incremental_mode TINYINT(1);

    -- TODO: add this Error handler dynamically to all the ETL procedures where it is not added already
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1

                @message_text = MESSAGE_TEXT,
                @mysql_errno = MYSQL_ERRNO,
                @returned_sqlstate = RETURNED_SQLSTATE;

            CALL sp_mamba_insert_error_log_table('sp_mamba_etl_user_settings_drop', @message_text, @mysql_errno,
                                                 @returned_sqlstate);

            UPDATE _mamba_etl_schedule
            SET end_time                 = NOW(),
                completion_status        = 'ERROR',
                transaction_status       = 'COMPLETED',
                success_or_error_message = CONCAT('sp_mamba_etl_scheduler_wrapper', ', ', @mysql_errno, ', ',
                                                  @message_text)
            WHERE id = (SELECT last_etl_schedule_insert_id FROM _mamba_etl_user_settings ORDER BY id DESC LIMIT 1);

            RESIGNAL;
        END;

    SELECT COUNT(1)
    INTO etl_ever_scheduled
    FROM _mamba_etl_schedule;

    SELECT incremental_mode_switch
    INTO incremental_mode
    FROM _mamba_etl_user_settings;

    IF etl_ever_scheduled = 0 OR incremental_mode = 0 THEN
        CALL sp_mamba_etl_schedule('sp_mamba_data_processing_drop_and_flatten');
    ELSE
        CALL sp_mamba_etl_schedule('sp_mamba_data_processing_increment_and_flatten');
    END IF;

END //

DELIMITER ;