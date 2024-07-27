-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_person_attribute_type mpat
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpat.person_attribute_type_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person_attribute_type pat
    ON mpat.person_attribute_type_id = pat.person_attribute_type_id
SET mpat.name               = pat.name,
    mpat.description        = pat.description,
    mpat.searchable         = pat.searchable,
    mpat.uuid               = pat.uuid,
    mpat.date_created       = pat.date_created,
    mpat.date_changed       = pat.date_changed,
    mpat.date_retired       = pat.date_retired,
    mpat.changed_by         = pat.changed_by,
    mpat.retired            = pat.retired,
    mpat.retired_by         = pat.retired_by,
    mpat.retire_reason      = pat.retire_reason,
    mpat.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END