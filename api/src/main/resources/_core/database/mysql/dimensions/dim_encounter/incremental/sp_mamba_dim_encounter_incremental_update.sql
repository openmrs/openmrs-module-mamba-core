-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Modified Encounters
UPDATE mamba_dim_encounter e
    INNER JOIN mamba_source_db.encounter enc
    ON e.encounter_id = enc.encounter_id
    INNER JOIN mamba_dim_encounter_type et
    ON e.encounter_type = et.encounter_type_id
SET e.encounter_id        = enc.encounter_id,
    e.uuid                = enc.uuid,
    e.encounter_type      = enc.encounter_type,
    e.encounter_type_uuid = et.uuid,
    e.patient_id          = enc.patient_id,
    e.visit_id            = enc.visit_id,
    e.encounter_datetime  = enc.encounter_datetime,
    e.date_created        = enc.date_created,
    e.date_changed        = enc.date_changed,
    e.changed_by          = enc.changed_by,
    e.date_voided         = enc.date_voided,
    e.voided              = enc.voided,
    e.voided_by           = enc.voided_by,
    e.void_reason         = enc.void_reason,
    e.incremental_record  = 1
WHERE enc.date_changed >= @starttime
   OR (enc.voided = 1 AND enc.date_voided >= @starttime);

-- $END