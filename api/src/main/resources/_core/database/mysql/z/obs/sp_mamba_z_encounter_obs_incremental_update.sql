-- $BEGIN
DECLARE starttime DATETIME;
SELECT  start_time INTO starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

-- Insert only new records
INSERT INTO mamba_z_encounter_obs
    (obs_id,
     encounter_id,
     person_id,
     obs_datetime,
     encounter_datetime,
     location_id,
     obs_group_id,
     encounter_type_uuid,
     obs_question_concept_id,
     obs_value_text,
     obs_value_numeric,
     obs_value_coded,
     obs_value_datetime,
     obs_value_complex,
     obs_value_drug,
     obs_question_uuid,
     obs_answer_uuid,
     obs_value_coded_uuid,
     status,
     voided,
     flag)
SELECT
    o.obs_id,
    o.encounter_id,
    person_id,
    obs_datetime,
    encounter_datetime,
    location_id,
    obs_group_id,
    encounter_type_uuid,
    o.concept_id     AS obs_question_concept_id,
    o.value_text     AS obs_value_text,
    o.value_numeric  AS obs_value_numeric,
    o.value_coded    AS obs_value_coded,
    o.value_datetime AS obs_value_datetime,
    o.value_complex  AS obs_value_complex,
    o.value_drug     AS obs_value_drug,
    NULL AS obs_question_uuid,
    NULL AS obs_answer_uuid,
    NULL AS obs_value_coded_uuid,
    status,
    o.voided,
    1  flag
FROM mamba_source_db.obs o
    INNER JOIN mamba_dim_encounter e
        ON o.encounter_id = e.encounter_id
WHERE o.encounter_id IS NOT NULL AND o.date_created >= starttime;


-- Update only modified records

-- update obs question UUIDs
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_metadata md
ON z.obs_question_concept_id = md.concept_id
    SET z.obs_question_uuid = md.concept_uuid
WHERE TRUE;

-- update obs_value_coded (UUIDs & Concept value names)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_name cn
ON z.obs_value_coded = cn.concept_id
    INNER JOIN mamba_dim_concept c
    ON c.concept_id = cn.concept_id
    SET z.obs_value_text       = cn.name,
        z.obs_value_coded_uuid = c.uuid
WHERE z.obs_value_coded IS NOT NULL;

-- Add and update column obs_value_boolean (Concept values)
ALTER TABLE mamba_z_encounter_obs
    ADD obs_value_boolean boolean;

UPDATE   mamba_z_encounter_obs z
SET obs_value_boolean =
        CASE
            WHEN obs_value_text IN ('FALSE','No') THEN 0
            WHEN obs_value_text IN ('TRUE','Yes') THEN 1
            ELSE NULL
            END
WHERE z.obs_value_coded IS NOT NULL
  AND  obs_question_concept_id in
       (SELECT
           DISTINCT concept_id
       FROM mamba_dim_concept c
                INNER JOIN mamba_dim_concept_datatype cd
                           ON c.datatype_id = cd.concept_datatype_id
       WHERE cd.datatype_name = 'Boolean');

-- $END