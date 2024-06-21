DROP PROCEDURE IF EXISTS sp_mamba_etl_execute_schedule_event;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_execute_schedule_event(IN query MEDIUMTEXT)
BEGIN

    SET @q = query;
    PREPARE stmt FROM @q;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;