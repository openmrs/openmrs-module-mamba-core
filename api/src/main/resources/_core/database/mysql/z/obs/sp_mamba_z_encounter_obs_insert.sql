DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_insert()
BEGIN
    DECLARE batch_size INT DEFAULT 1000000; -- 1m batch size
    DECLARE batch_last_obs_id INT DEFAULT 0;
    DECLARE last_obs_id INT;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_temp_obs_data AS
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
           md.concept_uuid  AS obs_question_uuid,
           NULL             AS obs_answer_uuid,
           NULL             AS obs_value_coded_uuid,
           e.encounter_type_uuid,
           o.status,
           o.previous_version,
           o.date_created,
           o.date_voided,
           o.voided,
           o.voided_by,
           o.void_reason
    FROM mamba_source_db.obs o
             INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
             INNER JOIN (SELECT DISTINCT concept_id, concept_uuid
                         FROM mamba_concept_metadata) md ON o.concept_id = md.concept_id
    WHERE o.encounter_id IS NOT NULL;

    CREATE INDEX idx_obs_id ON mamba_temp_obs_data (obs_id);

    SELECT MAX(obs_id) INTO last_obs_id FROM mamba_temp_obs_data;

    WHILE batch_last_obs_id < last_obs_id
        DO
            START TRANSACTION;
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
                                               date_created,
                                               date_voided,
                                               voided,
                                               voided_by,
                                               void_reason)
            SELECT obs_id,
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
                   date_created,
                   date_voided,
                   voided,
                   voided_by,
                   void_reason
            FROM mamba_temp_obs_data
            WHERE obs_id > batch_last_obs_id
            ORDER BY obs_id ASC
            LIMIT batch_size;
            COMMIT;

            SELECT MAX(obs_id)
            INTO batch_last_obs_id
            FROM mamba_z_encounter_obs
            LIMIT 1;

        END WHILE;

    DROP TEMPORARY TABLE IF EXISTS mamba_temp_obs_data;

END //

DELIMITER ;