-- $BEGIN

UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.datatype_name
WHERE c.id > 0;

UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_name cn
    ON c.concept_id = cn.concept_id
SET c.name = CONCAT(cn.name, '_', 'Retired')
WHERE c.retired = 1;

-- $END
