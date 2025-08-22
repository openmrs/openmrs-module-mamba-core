-- $BEGIN

-- Update the Data Type
UPDATE mamba_dim_concept c
 INNER JOIN mamba_dim_concept_datatype dt
 ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.name
WHERE c.concept_id > 0;

-- Create staging table with explicit collation for better performance
DROP TEMPORARY TABLE IF EXISTS mamba_temp_computed_concept_name;

CREATE TEMPORARY TABLE mamba_temp_computed_concept_name
(
 concept_id INT NOT NULL,
 concept_name VARCHAR(255),
 retired TINYINT(1),
 computed_name VARCHAR(255),
 tbl_column_name VARCHAR(60),
 INDEX mamba_idx_concept_id (concept_id)
);

-- Step 1: Insert raw data with proper JOIN to avoid collation issues
INSERT INTO mamba_temp_computed_concept_name (concept_id, concept_name, retired)
SELECT c.concept_id, 
 cn.name,
 c.retired
FROM mamba_dim_concept c
 LEFT JOIN mamba_dim_concept_name cn 
 ON c.concept_id = cn.concept_id
 AND cn.voided = 0; -- Filter to reduce data volume

-- Step 2: Update computed_name in a separate step
UPDATE mamba_temp_computed_concept_name
SET computed_name = CASE
 WHEN concept_name IS NULL OR TRIM(concept_name) = '' 
  THEN CONCAT('UNKNOWN_CONCEPT_NAME', '_', concept_id)
 WHEN retired = 1 
  THEN CONCAT(TRIM(concept_name), '_', 'RETIRED')
 ELSE TRIM(concept_name)
 END;

-- Step 3: Update tbl_column_name with optimized string operations
UPDATE mamba_temp_computed_concept_name
SET tbl_column_name = LEFT(
 LOWER(
  REPLACE(
   REPLACE(
    REPLACE(
     fn_mamba_remove_special_characters(
      fn_mamba_collapse_spaces(computed_name)
     ),
     ' ', '_'   -- Single space to underscore
    ),
    '__', '_'   -- Double underscore to single
   ),
   '__', '_'    -- Run again for triple underscores
  )
 ),
 60
);

-- Step 4: Final update to main table
UPDATE mamba_dim_concept c
 INNER JOIN mamba_temp_computed_concept_name tc
 ON c.concept_id = tc.concept_id
SET c.name = tc.computed_name,
 c.auto_table_column_name = IF(tc.tbl_column_name = '' OR tc.tbl_column_name IS NULL,
  CONCAT('UNKNOWN_CONCEPT_NAME', '_', c.concept_id),
  tc.tbl_column_name)
WHERE c.concept_id > 0;

DROP TEMPORARY TABLE IF EXISTS mamba_temp_computed_concept_name;

-- $END