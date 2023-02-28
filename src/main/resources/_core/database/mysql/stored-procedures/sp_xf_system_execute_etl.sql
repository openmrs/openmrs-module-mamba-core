DELIMITER //

DROP PROCEDURE IF EXISTS dbo.sp_xf_system_execute_etl;

CREATE PROCEDURE dbo.sp_xf_system_execute_etl()
BEGIN

    DECLARE start_time bigint;
    DECLARE end_time bigint;

    -- Fix start time in microseconds
    SET @start_time = (UNIX_TIMESTAMP(NOW()) * 1000000 + MICROSECOND(NOW(6)));

    call sp_data_processing();

    -- Fix end time in microseconds
    SET @end_time = (UNIX_TIMESTAMP(NOW()) * 1000000 + MICROSECOND(NOW(6)));

    -- Result
    select (@end_time - @start_time) / 1000;

END//

DELIMITER ;