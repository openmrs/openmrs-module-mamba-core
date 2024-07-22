-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only NEW Concepts
INSERT INTO mamba_dim_concept (uuid,
                               concept_id,
                               datatype_id,
                               retired,
                               date_created,
                               date_changed,
                               changed_by,
                               date_retired,
                               retired_by,
                               retire_reason,
                               incremental_record)
SELECT c.uuid          AS uuid,
       c.concept_id    AS concept_id,
       c.datatype_id   AS datatype_id,
       c.retired       AS retired,
       c.date_created  AS date_created,
       c.date_changed  AS date_changed,
       c.changed_by    AS changed_by,
       c.date_retired  AS date_retired,
       c.retired_by    AS retired_by,
       c.retire_reason AS retire_reason,
       1
FROM mamba_source_db.concept c
WHERE c.concept_id NOT IN (SELECT DISTINCT (concept_id) FROM mamba_dim_concept)
  AND c.date_created >= @starttime;

-- $END