DROP PROCEDURE IF EXISTS sp_mamba_etl_schedule_trim_log_event;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_schedule_trim_log_event()

BEGIN

    DELETE FROM _mamba_etl_schedule
    WHERE id NOT IN (
        SELECT id FROM (
                           SELECT id
                           FROM _mamba_etl_schedule
                           ORDER BY id DESC
                           LIMIT 20
                       ) AS recent_records
    );

END //

DELIMITER ;