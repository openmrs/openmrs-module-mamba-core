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
CREATE TEMPORARY TABLE mamba_temp_computed_concept_name
(
    concept_id      INT          NOT NULL,
    computed_name   VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tbl_column_name VARCHAR(60)  COLLATE utf8mb4_unicode_ci NOT NULL,
    INDEX mamba_idx_concept_id (concept_id)
)CHARSET = UTF8MB4 AS
SELECT c.concept_id,
       CASE
           WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = '' THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
           WHEN c.retired = 1 THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
           ELSE TRIM(cn.name)
           END COLLATE utf8mb4_unicode_ci AS computed_name,
       TRIM(LOWER(LEFT(REPLACE(REPLACE(fn_mamba_remove_special_characters(
                                               CASE
                                                   WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = ''
                                                       THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
                                                   WHEN c.retired = 1 THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
                                                   ELSE TRIM(cn.name)
                                                   END
                                       ) COLLATE utf8mb4_unicode_ci, ' ', '_'), '__', '_'), 60))) AS tbl_column_name
FROM mamba_dim_concept c
         LEFT JOIN mamba_dim_concept_name cn ON c.concept_id = cn.concept_id;

UPDATE mamba_dim_concept c
    INNER JOIN mamba_temp_computed_concept_name tc
    ON c.concept_id = tc.concept_id
SET c.name                   = tc.computed_name,
    c.auto_table_column_name = IF(tc.tbl_column_name = '',
                                  CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id),
                                  tc.tbl_column_name)
WHERE c.incremental_record = 1;

DROP TEMPORARY TABLE IF EXISTS mamba_temp_computed_concept_name;

-- $END