-- $BEGIN

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
 row_num)
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
    row_num
FROM
    mamba_source_db.obs o
        INNER JOIN
    mamba_dim_encounter e ON o.encounter_id = e.encounter_id
        INNER JOIN
    (SELECT
         obs_id,
         (@row_number := CASE
                          WHEN @prev_person_id = person_id
                                   AND @prev_encounter_id = o.encounter_id
                                   AND @prev_concept_id = concept_id
                          THEN @row_number + 1
                          ELSE 1
                       END) AS row_num,
         @prev_person_id := person_id,
        @prev_encounter_id := o.encounter_id,
        @prev_concept_id := concept_id
     FROM
         mamba_source_db.obs o
     WHERE
         o.encounter_id IS NOT NULL
     ORDER BY
         person_id, o.encounter_id, o.concept_id
    ) r on r.obs_id = o.obs_id
WHERE
    o.encounter_id IS NOT NULL;

-- $END