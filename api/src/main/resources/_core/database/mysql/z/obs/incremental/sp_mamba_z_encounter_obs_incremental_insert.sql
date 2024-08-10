-- $BEGIN

SET @row_number = 0;
SET @prev_person_id = NULL;
SET @prev_encounter_id = NULL;
SET @prev_concept_id = NULL;
SET @date_created = NULL;

-- Create the temporary table: mamba_temp_obs_row_num
CREATE TEMPORARY TABLE mamba_temp_obs_row_num
(
    obs_id       INT      NOT NULL,
    row_num      INT      NOT NULL,
    person_id    INT      NOT NULL,
    encounter_id INT      NOT NULL,
    concept_id   INT      NOT NULL,
    date_created DATETIME NOT NULL,

    INDEX mamba_idx_encounter_id (obs_id),
    INDEX mamba_idx_visit_id (row_num),
    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_encounter_datetime (encounter_id),
    INDEX mamba_idx_encounter_type_uuid (concept_id),
    INDEX mamba_idx_obs_question_concept_id (date_created)
)
    CHARSET = UTF8MB4;

-- insert into mamba_temp_obs_row_num
INSERT INTO mamba_temp_obs_row_num
SELECT obs_id,
       (@row_number := CASE
                           WHEN @prev_person_id = person_id
                               AND @prev_encounter_id = encounter_id
                               AND @prev_concept_id = concept_id
                               AND @date_created = date_created
                               THEN @row_number + 1
                           ELSE 1
           END)                           AS row_num,
       @prev_person_id := person_id       AS person_id,
       @prev_encounter_id := encounter_id AS encounter_id,
       @prev_concept_id := concept_id     AS concept_id,
       @date_created := date_created      AS date_created
FROM mamba_source_db.obs
WHERE encounter_id IS NOT NULL
ORDER BY person_id, encounter_id, concept_id, date_created;

-- Insert into mamba_z_encounter_obs
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
                                   void_reason,
                                   incremental_record)
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
       o.void_reason,
       1
FROM mamba_source_db.obs o
         INNER JOIN mamba_etl_incremental_columns_index_new ic ON o.obs_id = ic.incremental_table_pkey
         INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
         INNER JOIN mamba_temp_obs_row_num t ON o.obs_id = t.obs_id
WHERE o.encounter_id IS NOT NULL;

DROP TEMPORARY TABLE mamba_temp_obs_row_num;
-- $END