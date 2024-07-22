-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_encounter_type (encounter_type_id,
                                      uuid,
                                      name,
                                      description,
                                      retired,
                                      date_created,
                                      date_changed,
                                      changed_by,
                                      date_retired,
                                      retired_by,
                                      retire_reason,
                                      incremental_record)
SELECT et.encounter_type_id,
       et.uuid,
       et.name,
       et.description,
       et.retired,
       et.date_created,
       et.date_changed,
       et.changed_by,
       et.date_retired,
       et.retired_by,
       et.retire_reason,
       1
FROM mamba_source_db.encounter_type et
WHERE et.encounter_type_id NOT IN (SELECT DISTINCT (encounter_type_id) FROM mamba_dim_encounter_type)
  AND et.date_created >= @starttime;

-- $END