-- $BEGIN

-- Update the Data Type
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.name
WHERE c.concept_id > 0;

-- Update the concept name and table column name
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_name cn
    ON c.concept_id = cn.concept_id
SET c.name = IF(c.retired = 1, CONCAT(cn.name, '_', 'RETIRED'), cn.name),
    -- TODO: resolve column length issue first to add backticks. c.auto_table_column_name = CONCAT('`', LOWER(LEFT(REPLACE(REPLACE(fn_mamba_remove_special_characters(c.name), ' ', '_'),'__', '_'),60)), '`')
    c.auto_table_column_name = LOWER(LEFT(REPLACE(REPLACE(fn_mamba_remove_special_characters(c.name), ' ', '_'),'__', '_'),60))
WHERE c.concept_id > 0;

-- $END