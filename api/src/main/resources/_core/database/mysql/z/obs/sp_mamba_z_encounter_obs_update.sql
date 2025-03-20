DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_update;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_update()
BEGIN
    DECLARE v_total_records INT;
    DECLARE v_batch_size INT DEFAULT 100000; -- batch size
    DECLARE v_offset INT DEFAULT 0;
    DECLARE v_rows_affected INT;
    
    -- Use a transaction for better error handling and atomicity
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;
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
    WHERE concept_id in (SELECT DISTINCT obs_value_coded
                         FROM mamba_z_encounter_obs
                         WHERE obs_value_coded IS NOT NULL);
                         
    -- Create index to optimize joins
    CREATE INDEX mamba_idx_concept_id ON mamba_temp_value_coded_values (concept_id);

    -- Get total count for batch processing
    SELECT COUNT(*)
    INTO v_total_records
    FROM mamba_z_encounter_obs z
             INNER JOIN mamba_temp_value_coded_values mtv
                        ON z.obs_value_coded = mtv.concept_id
    WHERE z.obs_value_coded IS NOT NULL;

    -- Process records in batches to optimize memory usage
    WHILE v_offset < v_total_records DO
        -- Update in batches using dynamic SQL
        SET @sql = CONCAT('UPDATE mamba_z_encounter_obs z
                    INNER JOIN (
                        SELECT concept_id, concept_name, concept_uuid
                        FROM mamba_temp_value_coded_values mtv
                        LIMIT ', v_batch_size, ' OFFSET ', v_offset, '
                    ) AS mtv
                    ON z.obs_value_coded = mtv.concept_id
                    SET z.obs_value_text = mtv.concept_name,
                        z.obs_value_coded_uuid = mtv.concept_uuid
                    WHERE z.obs_value_coded IS NOT NULL');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        SET v_rows_affected = ROW_COUNT();
        DEALLOCATE PREPARE stmt;

        -- Adaptively adjust offset based on actual rows affected
        SET v_offset = v_offset + IF(v_rows_affected > 0, v_rows_affected, v_batch_size);
    END WHILE;

    -- Update boolean values based on text representations
    UPDATE mamba_z_encounter_obs z
    SET obs_value_boolean =
            CASE
                WHEN obs_value_text IN ('FALSE', 'No') THEN 0
                WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
                ELSE NULL
                END
    WHERE z.obs_value_coded IS NOT NULL
      AND obs_question_concept_id in
          (SELECT DISTINCT concept_id
           FROM mamba_dim_concept c
           WHERE c.datatype = 'Boolean');

    COMMIT;
    
    -- Clean up temporary resources
    DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;

END //

DELIMITER ;