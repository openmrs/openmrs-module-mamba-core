-- $BEGIN

-- Update the Data Type
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.name
WHERE c.concept_id > 0;

CREATE TEMPORARY TABLE mamba_temp_computed_concept_name
(
    concept_id      INT          NOT NULL,
    computed_name   VARCHAR(255) NOT NULL,
    tbl_column_name VARCHAR(60)  NOT NULL,
    INDEX mamba_idx_concept_id (concept_id)
)
    CHARSET = UTF8MB4
SELECT c.concept_id,
       CASE
           WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = '' THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
           WHEN c.retired = 1 THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
           ELSE TRIM(cn.name)
           END                                                         AS computed_name,
       TRIM(LOWER(LEFT(REPLACE(REPLACE(fn_mamba_remove_special_characters(
                                               CASE
                                                   WHEN TRIM(cn.name) IS NULL OR TRIM(cn.name) = ''
                                                       THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id)
                                                   WHEN c.retired = 1 THEN CONCAT(TRIM(cn.name), '_', 'RETIRED')
                                                   ELSE TRIM(cn.name)
                                                   END
                                       ), ' ', '_'), '__', '_'), 60))) AS tbl_column_name
FROM mamba_dim_concept c
         LEFT JOIN mamba_dim_concept_name cn ON c.concept_id = cn.concept_id;

UPDATE mamba_dim_concept c
    INNER JOIN mamba_temp_computed_concept_name tc
    ON c.concept_id = tc.concept_id
SET c.name                   = tc.computed_name,
    c.auto_table_column_name = IF(tc.tbl_column_name = '',
                                  CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id),
                                  tc.tbl_column_name)
WHERE c.concept_id > 0;

DROP TEMPORARY TABLE IF EXISTS mamba_temp_computed_concept_name;

-- $END