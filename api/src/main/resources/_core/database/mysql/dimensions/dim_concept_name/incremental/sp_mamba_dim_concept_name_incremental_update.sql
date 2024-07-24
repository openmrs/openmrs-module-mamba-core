-- $BEGIN
-- Update only Modified Records
UPDATE mamba_dim_concept_name cn
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON cn.concept_name_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.concept_name cnm
    ON cn.concept_name_id = cnm.concept_name_id
SET cn.concept_id         = cnm.concept_id,
    cn.name               = cnm.name,
    cn.locale             = cnm.locale,
    cn.locale_preferred   = cnm.locale_preferred,
    cn.voided             = cnm.voided,
    cn.concept_name_type  = cnm.concept_name_type,
    cn.date_changed       = cnm.date_changed,
    cn.changed_by         = cnm.changed_by,
    cn.voided_by          = cnm.voided_by,
    cn.date_voided        = cnm.date_voided,
    cn.void_reason        = cnm.void_reason,
    cn.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END