DROP PROCEDURE IF EXISTS sp_mamba_XXXXXXX;

DELIMITER //

CREATE PROCEDURE sp_mamba_XXXXXXX()
BEGIN

    SET @etl_schedule_table_count := 1;
    SET @etl_stored_procedure_to_run := NULL;

-- make this dynamic
    SELECT COUNT(*)
    INTO @etl_schedule_table_count
    FROM information_schema.tables
    WHERE table_schema = 'analysis_db'
      AND table_name = '_mamba_etl_schedule';

    IF @etl_schedule_table_count < 1 THEN
        CALL sp_mamba_etl_schedule_table_create;
        SET @etl_stored_procedure_to_run := 'sp_mamba_data_processing_flatten';
    ELSE
        SET @etl_stored_procedure_to_run := 'sp_mamba_data_processing_flatten_incremental';
    END IF;

    CALL sp_mamba_etl_schedule(@etl_stored_procedure_to_run);

END //

DELIMITER ;


