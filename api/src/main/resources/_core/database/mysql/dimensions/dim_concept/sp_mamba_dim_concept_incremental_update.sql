-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

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
       c.name,
       1                flag
FROM mamba_source_db.concept c
where c.date_created >= @starttime;

-- Update only modified records
UPDATE mamba_dim_concept dc
    INNER JOIN mamba_source_db.concept c
    ON dc.concept_id = c.concept_id
SET dc.uuid        = c.uuid,
    dc.name        = c.name,
    dc.datatype_id = c.datatype_id,
    dc.retired     = c.retired,
    dc.flag        = 2
WHERE c.date_changed >= @starttime;

-- $END