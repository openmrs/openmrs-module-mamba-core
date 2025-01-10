-- $BEGIN

-- Insert only new Records
INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    name,
                                    locale,
                                    locale_preferred,
                                    voided,
                                    concept_name_type,
                                    date_created,
                                    date_changed,
                                    changed_by,
                                    voided_by,
                                    date_voided,
                                    void_reason,
                                    incremental_record)
SELECT cn.concept_name_id,
       cn.concept_id,
       cn.name,
       cn.locale COLLATE utf8mb4_general_ci,
       cn.locale_preferred,
       cn.voided,
       cn.concept_name_type,
       cn.date_created,
       cn.date_changed,
       cn.changed_by,
       cn.voided_by,
       cn.date_voided,
       cn.void_reason,
       1
FROM mamba_source_db.concept_name cn
         INNER JOIN mamba_etl_incremental_columns_index_new ic
                    ON cn.concept_name_id = ic.incremental_table_pkey
WHERE cn.locale COLLATE utf8mb4_general_ci IN (
    SELECT DISTINCT(concepts_locale) COLLATE utf8mb4_general_ci 
    FROM _mamba_etl_user_settings
)
  AND IF(cn.locale_preferred = 1, cn.locale_preferred = 1, cn.concept_name_type = 'FULLY_SPECIFIED')
  AND cn.voided = 0;

-- $END