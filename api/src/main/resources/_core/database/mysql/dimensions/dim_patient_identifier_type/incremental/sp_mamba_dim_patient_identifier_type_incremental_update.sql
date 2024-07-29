-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_patient_identifier_type mdpit
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mdpit.patient_identifier_type_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.patient_identifier_type pit
    ON mdpit.patient_identifier_type_id = pit.patient_identifier_type_id
SET mdpit.name               = pit.name,
    mdpit.description        = pit.description,
    mdpit.uuid               = pit.uuid,
    mdpit.date_created       = pit.date_created,
    mdpit.date_changed       = pit.date_changed,
    mdpit.date_retired       = pit.date_retired,
    mdpit.retired            = pit.retired,
    mdpit.retire_reason      = pit.retire_reason,
    mdpit.retired_by         = pit.retired_by,
    mdpit.changed_by         = pit.changed_by,
    mdpit.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END