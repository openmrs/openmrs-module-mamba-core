-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only NEW Obs (determined by date_created)
INSERT INTO mamba_z_encounter_obs (obs_id,
                                   encounter_id,
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
                                   void_reason,
                                   incremental_record)
SELECT o.obs_id,
       o.encounter_id,
       person_id,
       order_id,
       encounter_datetime,
       obs_datetime,
       location_id,
       obs_group_id,
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
       encounter_type_uuid,
       status,
       previous_version,
       row_num,
       o.date_created,
       o.date_voided,
       o.voided,
       o.voided_by,
       o.void_reason,
       1
FROM mamba_source_db.obs o
         INNER JOIN mamba_dim_encounter e
                    ON o.encounter_id = e.encounter_id
WHERE o.encounter_id IS NOT NULL
  AND o.obs_id NOT IN (SELECT obs_id FROM mamba_z_encounter_obs)
  AND o.date_created >= @starttime;

-- $END