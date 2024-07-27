-- $BEGIN

-- Modified Encounter types
UPDATE mamba_dim_encounter_type et
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON et.encounter_type_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.encounter_type ent
    ON et.encounter_type_id = ent.encounter_type_id
SET et.uuid               = ent.uuid,
    et.name               = ent.name,
    et.description        = ent.description,
    et.retired            = ent.retired,
    et.date_created       = ent.date_created,
    et.date_changed       = ent.date_changed,
    et.changed_by         = ent.changed_by,
    et.date_retired       = ent.date_retired,
    et.retired_by         = ent.retired_by,
    et.retire_reason      = ent.retire_reason,
    et.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END