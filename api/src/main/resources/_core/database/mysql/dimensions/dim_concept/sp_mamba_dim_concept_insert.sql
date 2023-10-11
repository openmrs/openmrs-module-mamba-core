-- $BEGIN

INSERT INTO mamba_dim_concept (uuid,
                               concept_id,
                               datatype_id,
                               retired)
SELECT c.uuid        AS uuid,
       c.concept_id  AS concept_id,
       c.datatype_id AS datatype_id,
       c.retired
FROM mamba_source_db.concept c;
-- WHERE c.retired = 0;

-- $END