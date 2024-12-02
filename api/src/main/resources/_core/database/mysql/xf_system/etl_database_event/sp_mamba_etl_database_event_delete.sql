-- $BEGIN

DELETE processed_event
FROM _mamba_etl_database_event processed_event
         INNER JOIN mamba_etl_incremental_columns_index_all incremental_record
                    ON processed_event.id = incremental_record.mamba_etl_database_event_id
WHERE incremental_record.mamba_etl_database_event_id IS NOT NULL;

-- $END