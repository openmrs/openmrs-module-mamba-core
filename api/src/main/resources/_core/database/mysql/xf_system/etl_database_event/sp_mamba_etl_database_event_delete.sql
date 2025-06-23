-- $BEGIN

DELETE
FROM _mamba_etl_database_event
WHERE id IN (SELECT incremental_record.mamba_etl_database_event_id
             FROM mamba_etl_incremental_columns_index_all incremental_record);

-- $END