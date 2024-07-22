-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Modified Encounter types
UPDATE mamba_dim_encounter_type et
    INNER JOIN mamba_source_db.encounter_type ent
    ON et.encounter_type_id = ent.encounter_type_id
SET et.uuid               = ent.uuid,
    et.name               = ent.name,
    et.description        = ent.description,
    et.retired            = ent.retired,
    et.date_created       = ent.date_created,
    et.date_changed       = ent.date_changed,
    et.changed_by         = ent.changed_by,
    et.date_retired       = ent.date_retired,
    et.retired_by         = ent.retired_by,
    et.retire_reason      = ent.retire_reason,
    et.incremental_record = 1
WHERE ent.date_changed >= @starttime
   OR (ent.retired = 1 AND ent.date_retired >= @starttime);

-- $END