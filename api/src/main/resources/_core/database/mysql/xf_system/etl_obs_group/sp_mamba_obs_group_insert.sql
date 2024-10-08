DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_insert()
BEGIN
    DECLARE total_records INT;
    DECLARE batch_size INT DEFAULT 1000000; -- 1 million records per batch
    DECLARE mamba_offset INT DEFAULT 0;

    -- Calculate total records to process
SELECT COUNT(*)
INTO total_records
FROM mamba_source_db.obs o
         INNER JOIN mamba_dim_encounter e ON o.encounter_id = e.encounter_id
         INNER JOIN (SELECT DISTINCT concept_id, concept_uuid
                     FROM mamba_concept_metadata) md ON o.concept_id = md.concept_id
WHERE o.encounter_id IS NOT NULL;

-- Loop through the batches of records
WHILE mamba_offset < total_records
    DO
        -- Create a temporary table to store obs group information
        CREATE TEMPORARY TABLE mamba_temp_obs_group_ids
        (
            obs_group_id INT NOT NULL,
            row_num      INT NOT NULL,
            INDEX mamba_idx_obs_group_id (obs_group_id),
            INDEX mamba_idx_row_num (row_num)
        )
        CHARSET = UTF8MB4;

        -- Insert into the temporary table based on obs group aggregation
        SET @sql_temp_insert = CONCAT('
            INSERT INTO mamba_temp_obs_group_ids
            SELECT obs_group_id, COUNT(*) AS row_num
            FROM mamba_z_encounter_obs o
            WHERE obs_group_id IS NOT NULL
            GROUP BY obs_group_id, person_id, encounter_id
            LIMIT ', batch_size, ' OFFSET ', mamba_offset);

PREPARE stmt_temp_insert FROM @sql_temp_insert;
EXECUTE stmt_temp_insert;
DEALLOCATE PREPARE stmt_temp_insert;

-- Insert into the final table from the temp table, including concept data
SET @sql_obs_group_insert = CONCAT('
            INSERT INTO mamba_obs_group (obs_group_concept_id, obs_group_concept_name, obs_id)
            SELECT DISTINCT o.obs_question_concept_id,
                            LEFT(c.auto_table_column_name, 12) AS name,
                            o.obs_id
            FROM mamba_temp_obs_group_ids t
                     INNER JOIN mamba_z_encounter_obs o ON t.obs_group_id = o.obs_group_id
                     INNER JOIN mamba_dim_concept c ON o.obs_question_concept_id = c.concept_id
            WHERE t.row_num > 1
            LIMIT ', batch_size, ' OFFSET ', mamba_offset);

PREPARE stmt_obs_group_insert FROM @sql_obs_group_insert;
EXECUTE stmt_obs_group_insert;
DEALLOCATE PREPARE stmt_obs_group_insert;

-- Drop the temporary table after processing each batch
DROP TEMPORARY TABLE IF EXISTS mamba_temp_obs_group_ids;

        -- Increment the offset for the next batch
        SET mamba_offset = mamba_offset + batch_size;

END WHILE;
END //

DELIMITER ;
