-- $BEGIN

-- Use a temporary table to store row numbers
CREATE TEMPORARY TABLE mamba_temp_obs_row_num AS
SELECT obs_id,
       (@row_number := CASE
                           WHEN @prev_person_id = person_id
                               AND @prev_encounter_id = encounter_id
                               AND @prev_concept_id = concept_id
                               THEN @row_number + 1
                           ELSE 1
           END) AS row_num,
       @prev_person_id := person_id,
       @prev_encounter_id := encounter_id,
       @prev_concept_id := concept_id
FROM mamba_source_db.obs
WHERE encounter_id IS NOT NULL
ORDER BY person_id, encounter_id, concept_id;

INSERT INTO mamba_z_encounter_obs (obs_id,
                                   encounter_id,
                                   visit_id,
                                   person_id,
                                   order_id,
                                   encounter_datetime,
                                   obs_datetime,
                                   location_id,
                                   obs_group_id,
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
                                   encounter_type_uuid,
                                   status,
                                   previous_version,
                                   row_num,
                                   date_created,
                                   date_voided,
                                   voided,
                                   voided_by,
                                   void_reason)
SELECT o.obs_id,
       o.encounter_id,
       e.visit_id,
       o.person_id,
       o.order_id,
       e.encounter_datetime,
       o.obs_datetime,
       o.location_id,
       o.obs_group_id,
       o.concept_id     AS obs_question_concept_id,
       o.value_text     AS obs_value_text,
       o.value_numeric  AS obs_value_numeric,
       o.value_coded    AS obs_value_coded,
       o.value_datetime AS obs_value_datetime,
       o.value_complex  AS obs_value_complex,
       o.value_drug     AS obs_value_drug,
       NULL             AS obs_question_uuid,
       NULL             AS obs_answer_uuid,
       NULL             AS obs_value_coded_uuid,
       e.encounter_type_uuid,
       o.status,
       o.previous_version,
       t.row_num,
       o.date_created,
       o.date_voided,
       o.voided,
       o.voided_by,
       o.void_reason
FROM mamba_source_db.obs o
         INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
         INNER JOIN mamba_temp_obs_row_num t ON o.obs_id = t.obs_id
WHERE o.encounter_id IS NOT NULL;

-- Drop the temporary table
DROP TEMPORARY TABLE mamba_temp_obs_row_num;

-- $END