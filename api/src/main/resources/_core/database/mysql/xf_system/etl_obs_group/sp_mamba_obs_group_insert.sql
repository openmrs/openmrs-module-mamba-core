DROP PROCEDURE IF EXISTS sp_mamba_obs_group_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_obs_group_insert()
BEGIN
    DECLARE batch_size INT DEFAULT 1000000; -- 1M batch size
    DECLARE min_group_id INT;
    DECLARE max_group_id INT;
    DECLARE current_id INT;

    -- Calculate range for obs_group_id
    SELECT MIN(obs_group_id), MAX(obs_group_id)
    INTO min_group_id, max_group_id
    FROM mamba_z_encounter_obs
    WHERE obs_group_id IS NOT NULL;

    SET current_id = min_group_id;

    WHILE current_id <= max_group_id DO
        -- Create a temporary table to store obs group information for current batch
        CREATE TEMPORARY TABLE IF NOT EXISTS mamba_temp_obs_group_ids (
            obs_group_id INT NOT NULL,
            row_count INT NOT NULL,
            INDEX mamba_idx_obs_group_id (obs_group_id)
        );

        TRUNCATE TABLE mamba_temp_obs_group_ids;

        -- Insert into the temporary table based on obs group aggregation within ID range
        INSERT INTO mamba_temp_obs_group_ids (obs_group_id, row_count)
        SELECT obs_group_id, COUNT(*) AS row_count
        FROM mamba_z_encounter_obs
        WHERE obs_group_id >= current_id 
          AND obs_group_id < (current_id + batch_size)
        GROUP BY obs_group_id, person_id, encounter_id;

        -- Insert into the final table from the temp table, including concept data
        INSERT INTO mamba_obs_group (obs_group_concept_id, obs_group_concept_name, obs_id, obs_group_id)
        SELECT DISTINCT 
            o.obs_question_concept_id,
            LEFT(c.auto_table_column_name, 12) AS name,
            o.obs_id,
            o.obs_group_id
        FROM mamba_temp_obs_group_ids t
        INNER JOIN mamba_z_encounter_obs o ON t.obs_group_id = o.obs_group_id
        INNER JOIN mamba_dim_concept c ON o.obs_question_concept_id = c.concept_id
        WHERE t.row_count > 1;

        DROP TEMPORARY TABLE IF EXISTS mamba_temp_obs_group_ids;

        SET current_id = current_id + batch_size;
    END WHILE;
END //

DELIMITER ;
