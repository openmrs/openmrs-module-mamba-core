-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_concept tc
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON tc.concept_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.concept sc
    ON tc.concept_id = sc.concept_id
SET tc.uuid               = sc.uuid,
    tc.datatype_id        = sc.datatype_id,
    tc.date_created       = sc.date_created,
    tc.date_changed       = sc.date_changed,
    tc.date_retired       = sc.date_retired,
    tc.changed_by         = sc.changed_by,
    tc.retired            = sc.retired,
    tc.retired_by         = sc.retired_by,
    tc.retire_reason      = sc.retire_reason,
    tc.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- Update the Data Type
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.name
WHERE c.incremental_record = 1;

-- Update the concept name and table column name
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_name cn
    ON c.concept_id = cn.concept_id
SET c.name = IF(c.retired = 1, CONCAT(cn.name, '_', 'RETIRED'), cn.name),
    c.auto_table_column_name = LOWER(LEFT(REPLACE(REPLACE(fn_mamba_remove_special_characters(c.name), ' ', '_'),'__', '_'),60))
WHERE c.incremental_record = 1;

-- $END