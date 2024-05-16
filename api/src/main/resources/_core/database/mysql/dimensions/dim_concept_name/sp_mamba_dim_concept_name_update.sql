-- $BEGIN

UPDATE mamba_dim_concept_name cn
    INNER JOIN mamba_dim_concept c
    ON cn.concept_id = c.concept_id
SET cn.name = CONCAT(cn.name, '_', 'Retired')
WHERE c.retired = 1;

-- $END