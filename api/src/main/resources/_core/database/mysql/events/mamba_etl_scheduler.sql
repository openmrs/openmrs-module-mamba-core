SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS events_mamba_etl
    ON SCHEDULE EVERY ? MINUTE
    DO
    BEGIN

        DECLARE etl_schedule_table_count INT DEFAULT 1;

        -- TODO: make etl table name dynamic
        SELECT COUNT(*)
        INTO etl_schedule_table_count
        FROM information_schema.tables
        WHERE table_schema = 'analysis_db'
          AND table_name = '_mamba_etl_schedule';

        IF etl_schedule_table_count < 1 THEN
            CALL sp_mamba_etl_schedule('sp_mamba_data_processing_flatten');
        ELSE
            CALL sp_mamba_etl_schedule('sp_mamba_data_processing_flatten_incremental');
        END IF;

    END;