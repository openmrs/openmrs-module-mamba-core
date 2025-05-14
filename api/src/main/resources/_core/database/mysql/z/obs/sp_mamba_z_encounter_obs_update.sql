DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_update;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_update()
BEGIN
    DECLARE v_batch_size INT DEFAULT 100000; -- Adjusted batch size, consider tuning this
    DECLARE v_offset INT DEFAULT 0;
    DECLARE v_rows_affected INT;
    DECLARE v_temp_total_records INT DEFAULT 0;

    -- Use a transaction for better error handling and atomicity
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;
        DROP TEMPORARY TABLE IF EXISTS temp_boolean_concept_ids;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An error occurred during the update process';
    END;

    START TRANSACTION;

    -- Create temporary table with only the needed values
    -- This reduces memory usage and improves join performance
    CREATE TEMPORARY TABLE mamba_temp_value_coded_values
        CHARSET = UTF8MB4 AS
    SELECT m.concept_id AS concept_id,
           m.uuid       AS concept_uuid,
           m.name       AS concept_name
    FROM mamba_dim_concept m
    WHERE concept_id IN (SELECT DISTINCT obs_value_coded
                         FROM mamba_z_encounter_obs
                         WHERE obs_value_coded IS NOT NULL);

    -- Create index to optimize joins
    CREATE INDEX mamba_idx_concept_id ON mamba_temp_value_coded_values (concept_id);

    -- Get total count from the temporary table for batch processing
    SELECT COUNT(*) INTO v_temp_total_records FROM mamba_temp_value_coded_values;

    -- Process records in batches to optimize memory usage
    WHILE v_offset < v_temp_total_records DO
        -- Update in batches using dynamic SQL
        SET @sql = CONCAT('UPDATE mamba_z_encounter_obs z
                    INNER JOIN (
                        SELECT concept_id, concept_name, concept_uuid
                        FROM mamba_temp_value_coded_values
                        ORDER BY concept_id -- Added ORDER BY for stable LIMIT/OFFSET
                        LIMIT ', v_batch_size, ' OFFSET ', v_offset, '
                    ) AS mtv_batch
                    ON z.obs_value_coded = mtv_batch.concept_id
                    SET z.obs_value_text = mtv_batch.concept_name,
                        z.obs_value_coded_uuid = mtv_batch.concept_uuid');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        SET v_rows_affected = ROW_COUNT(); -- Still useful for logging or potential future adaptive logic
        DEALLOCATE PREPARE stmt;

        SET v_offset = v_offset + v_batch_size; -- Corrected offset increment
    END WHILE;

    -- Prepare for boolean update: create a temp table for boolean concept IDs
    CREATE TEMPORARY TABLE temp_boolean_concept_ids (concept_id INT PRIMARY KEY)
        CHARSET = UTF8MB4 AS
    SELECT DISTINCT concept_id
    FROM mamba_dim_concept c
    WHERE c.datatype = 'Boolean';

    -- Update boolean values based on text representations
    UPDATE mamba_z_encounter_obs z
    INNER JOIN temp_boolean_concept_ids bci ON z.obs_question_concept_id = bci.concept_id
    SET obs_value_boolean =
            CASE
                WHEN z.obs_value_text IN ('FALSE', 'No') THEN 0
                WHEN z.obs_value_text IN ('TRUE', 'Yes') THEN 1
                ELSE NULL -- Or z.obs_value_boolean to keep existing if no match
            END
    WHERE z.obs_value_text IN ('FALSE', 'No', 'TRUE', 'Yes'); -- Process only relevant rows

    COMMIT;

    -- Clean up temporary resources
    DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;
    DROP TEMPORARY TABLE IF EXISTS temp_boolean_concept_ids;

END //

DELIMITER ;