-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Update only modified Obs

-- Update voided Obs (FINAL & AMENDED pair obs are incremental 1 though we shall not consider them in incremental flattening)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_source_db.obs o
    ON z.obs_id = o.obs_id
SET z.voided             = o.voided,
    z.voided_by          = o.voided_by,
    z.date_voided        = o.date_voided,
    z.void_reason        = o.void_reason,
    z.incremental_record = 1
WHERE o.voided = 1
  AND o.date_voided IS NOT NULL
  AND o.date_voided >= @starttime;

-- update obs question UUIDs for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_metadata md
    ON z.obs_question_concept_id = md.concept_id
SET z.obs_question_uuid = md.concept_uuid
WHERE z.incremental_record = 1
  AND z.voided = 0;

-- update obs_value_coded (UUIDs & Concept value names) for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept c
    ON z.obs_value_coded = c.concept_id
SET z.obs_value_text       = c.name,
    z.obs_value_coded_uuid = c.uuid
WHERE z.incremental_record = 1
  AND z.voided = 0
  AND z.obs_value_coded IS NOT NULL;

-- update column obs_value_boolean (Concept values) for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
SET obs_value_boolean =
        CASE
            WHEN obs_value_text IN ('FALSE', 'No') THEN 0
            WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
            ELSE NULL
            END
WHERE z.incremental_record = 1
  AND z.voided = 0
  AND z.obs_value_coded IS NOT NULL
  AND obs_question_concept_id in
      (SELECT DISTINCT concept_id
       FROM mamba_dim_concept c
       WHERE c.datatype = 'Boolean');

-- $END