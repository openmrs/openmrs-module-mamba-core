-- $BEGIN
-- Insert only new records
INSERT INTO mamba_dim_concept (uuid,
                               concept_id,
                               datatype_id,
                               retired,
                               name,
                               flag)
SELECT c.uuid        AS uuid,
       c.concept_id  AS concept_id,
       c.datatype_id AS datatype_id,
       c.retired,
       name,
       1 flag
FROM mamba_source_db.concept c
where c.date_created >= '2023-11-30 00:00:00';

-- Update only modified records
UPDATE mamba_dim_concept dc
    INNER JOIN mamba_source_db.concept c
    SET dc.uuid = dc.uuid ,
        dc.concept_id = c.concept_id,
        dc.datatype_id = c.datatype_id,
        dc.retired = c.retired,
        dc.flag = 2
WHERE c.date_changed >= '2023-11-30 00:00:00';


-- $END