DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_update;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_update()
BEGIN
    DECLARE batch_size INT DEFAULT 1000000; -- 1M batch size
    DECLARE min_encounter_id INT;
    DECLARE max_encounter_id INT;
    DECLARE current_id INT;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_temp_value_coded_values AS
    SELECT m.concept_id AS concept_id,
           m.uuid AS concept_uuid,
           m.name AS concept_name
    FROM mamba_dim_concept m
    WHERE concept_id IN (SELECT DISTINCT obs_value_coded
                         FROM mamba_z_encounter_obs
                         WHERE obs_value_coded IS NOT NULL);

    CREATE INDEX mamba_idx_concept_id ON mamba_temp_value_coded_values (concept_id);

    -- Get ID range for batching
    SELECT MIN(encounter_id), MAX(encounter_id) 
    INTO min_encounter_id, max_encounter_id 
    FROM mamba_z_encounter_obs;

    SET current_id = min_encounter_id;

    -- Update obs_value_coded (UUIDs & Concept value names) using ID range
    WHILE current_id <= max_encounter_id DO
        UPDATE mamba_z_encounter_obs z
        INNER JOIN mamba_temp_value_coded_values mtv ON z.obs_value_coded = mtv.concept_id
        SET z.obs_value_text = mtv.concept_name,
            z.obs_value_coded_uuid = mtv.concept_uuid
        WHERE z.obs_value_coded IS NOT NULL
          AND z.encounter_id >= current_id 
          AND z.encounter_id < (current_id + batch_size);

        SET current_id = current_id + batch_size;
    END WHILE;

    -- Update column obs_value_boolean (Concept values) - Already using efficient update but can be batched if needed
    -- For now, keeping it as is as it filters by specific concepts
    UPDATE mamba_z_encounter_obs z
    SET obs_value_boolean =
        CASE
            WHEN obs_value_text IN ('FALSE', 'No') THEN 0
            WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
            ELSE NULL
        END
    WHERE z.obs_value_coded IS NOT NULL
      AND obs_question_concept_id IN (
          SELECT DISTINCT concept_id
          FROM mamba_dim_concept c
          WHERE c.datatype = 'Boolean'
      );

    DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;

END //

DELIMITER ;