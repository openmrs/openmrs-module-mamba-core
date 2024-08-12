DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_insert()
BEGIN
    DECLARE total_records INT;
    DECLARE batch_size INT DEFAULT 1000000; -- 1 million batches
    DECLARE offset INT DEFAULT 0;

    SELECT COUNT(*)
    INTO total_records
    FROM openmrs.obs o
             INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
             INNER JOIN (SELECT DISTINCT concept_id, concept_uuid
                         FROM mamba_concept_metadata) md ON o.concept_id = md.concept_id
    WHERE o.encounter_id IS NOT NULL;

    WHILE offset < total_records
        DO
            SET @sql = CONCAT('INSERT INTO mamba_z_encounter_obs (obs_id,
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
            WHERE o.encounter_id IS NOT NULL
            ORDER BY o.obs_id ASC -- Use a unique column for ordering to avoid the duplicates error because of using offset
            LIMIT ', batch_size, ' OFFSET ', offset);

            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SET offset = offset + batch_size;
        END WHILE;
END //

DELIMITER ;