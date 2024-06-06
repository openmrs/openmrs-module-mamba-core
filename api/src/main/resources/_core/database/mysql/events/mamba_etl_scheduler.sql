-- SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS events_mamba_etl
    ON SCHEDULE EVERY ? MINUTE
    DO
    BEGIN
        DECLARE status ENUM ('RUNNING', 'COMPLETED');
        DECLARE etl_first_run bool DEFAULT true;
        DECLARE total INT;

        insert into _mamba_event_is_running () values ();

        -- make this dynamic
        SELECT COUNT(*)
        INTO total
        FROM information_schema.tables
        WHERE table_schema = 'analysis_db'
          AND table_name = '_mamba_etl_schedule';

        IF total = 1 THEN
            CALL sp_mamba_data_processing_etl();

        ELSE
            SELECT transaction_status
            INTO status
            FROM _mamba_etl_schedule
            ORDER BY id DESC
            LIMIT 1;

            IF status IS NULL OR status = 'COMPLETED' THEN
                CALL sp_mamba_etl_schedule();
            END IF;
        END IF;
    END;