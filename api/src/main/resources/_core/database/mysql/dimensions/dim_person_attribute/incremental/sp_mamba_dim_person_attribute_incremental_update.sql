-- $BEGIN

-- Modified Persons
UPDATE mamba_dim_person_attribute mpa
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpa.person_attribute_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person_attribute pa
    ON mpa.person_attribute_id = pa.person_attribute_id
SET mpa.person_attribute_id = pa.person_attribute_id,
    mpa.person_id           = pa.person_id,
    mpa.uuid                = pa.uuid,
    mpa.value               = pa.value,
    mpa.date_created        = pa.date_created,
    mpa.date_changed        = pa.date_changed,
    mpa.date_voided         = pa.date_voided,
    mpa.changed_by          = pa.changed_by,
    mpa.voided              = pa.voided,
    mpa.voided_by           = pa.voided_by,
    mpa.void_reason         = pa.void_reason,
    mpa.incremental_record  = 1
WHERE im.incremental_table_pkey > 1;

-- $END