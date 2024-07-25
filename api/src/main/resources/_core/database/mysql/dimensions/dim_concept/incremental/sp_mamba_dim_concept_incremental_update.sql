-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_concept tc
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON tc.concept_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.concept sc
    ON tc.concept_id = sc.concept_id
SET tc.uuid               = sc.uuid,
    tc.datatype_id        = sc.datatype_id,
    tc.retired            = sc.retired,
    tc.retired_by         = sc.retired_by,
    tc.retire_reason      = sc.retire_reason,
    tc.date_retired       = sc.date_retired,
    tc.date_changed       = sc.date_changed,
    tc.changed_by         = sc.changed_by,
    tc.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- Update the Data Type
UPDATE mamba_dim_concept sc
    INNER JOIN mamba_dim_concept_datatype dt
    ON sc.datatype_id = dt.concept_datatype_id
SET sc.datatype = dt.datatype_name
WHERE sc.incremental_record = 1;

-- Update the concept name
UPDATE mamba_dim_concept sc
    INNER JOIN mamba_dim_concept_name cn
    ON sc.concept_id = cn.concept_id
SET sc.name = IF(sc.retired = 1, CONCAT(cn.name, '_', 'RETIRED'), cn.name)
WHERE sc.incremental_record = 1;

-- $END