-- $BEGIN

UPDATE [analysis_db].mamba_dim_concept c
    INNER JOIN [analysis_db].mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.datatype_name
WHERE c.id > 0;

-- $END
