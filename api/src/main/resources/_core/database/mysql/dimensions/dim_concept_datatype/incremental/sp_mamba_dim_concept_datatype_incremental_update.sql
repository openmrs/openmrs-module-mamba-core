-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_concept_datatype mcd
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mcd.concept_datatype_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.concept_datatype cd
    ON mcd.concept_datatype_id = cd.concept_datatype_id
SET mcd.name               = cd.name,
    mcd.hl7_abbreviation   = cd.hl7_abbreviation,
    mcd.description        = cd.description,
    mcd.date_created       = cd.date_created,
    mcd.date_retired       = cd.date_retired,
    mcd.retired            = cd.retired,
    mcd.retired_by         = cd.retired_by,
    mcd.retire_reason      = cd.retire_reason,
    mcd.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END