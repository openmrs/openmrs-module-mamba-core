-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Update only modified records
UPDATE mamba_dim_concept dc
    INNER JOIN mamba_source_db.concept c
    ON dc.concept_id = c.concept_id
SET dc.uuid               = c.uuid,
    dc.datatype_id        = c.datatype_id,
    dc.retired            = c.retired,
    dc.retired_by         = c.retired_by,
    dc.retire_reason      = c.retire_reason,
    dc.date_retired       = c.date_retired,
    dc.date_changed       = c.date_changed,
    dc.changed_by         = c.changed_by,
    dc.incremental_record = 1
WHERE c.date_changed >= @starttime
   OR (c.retired = 1 AND c.date_retired >= @starttime);

-- Update the Data Type
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_datatype dt
    ON c.datatype_id = dt.concept_datatype_id
SET c.datatype = dt.datatype_name
WHERE c.incremental_record = 1;

-- Update the concept name
UPDATE mamba_dim_concept c
    INNER JOIN mamba_dim_concept_name cn
    ON c.concept_id = cn.concept_id
SET c.name = IF(c.retired = 1, CONCAT(cn.name, '_', 'RETIRED'), cn.name)
WHERE c.incremental_record = 1;

-- $END