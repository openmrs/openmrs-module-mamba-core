-- $BEGIN

-- update obs question UUIDs
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_concept_metadata md
    ON z.obs_question_concept_id = md.concept_id
SET z.obs_question_uuid = md.concept_uuid
WHERE z.obs_id > 0;

-- update obs_value_coded (UUIDs & Concept value names)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept c
    ON z.obs_value_coded = c.concept_id
SET z.obs_value_text       = c.name,
    z.obs_value_coded_uuid = c.uuid
WHERE z.obs_value_coded IS NOT NULL;

-- update column obs_value_boolean (Concept values)
UPDATE mamba_z_encounter_obs z
SET obs_value_boolean =
        CASE
            WHEN obs_value_text IN ('FALSE', 'No') THEN 0
            WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
            ELSE NULL
            END
WHERE z.obs_value_coded IS NOT NULL
  AND obs_question_concept_id in
      (SELECT DISTINCT concept_id
       FROM mamba_dim_concept c
       WHERE c.datatype = 'Boolean');

-- $END