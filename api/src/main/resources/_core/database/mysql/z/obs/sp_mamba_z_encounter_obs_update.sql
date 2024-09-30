DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_update;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_update()
BEGIN
    DECLARE batch_size INT DEFAULT 1000000; -- 1m batch size
    DECLARE batch_last_obs_id INT DEFAULT 0;
    DECLARE last_obs_id INT;

    -- Step 1: Create Temp Table once for concepts with obs_value_coded
    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_temp_value_coded_values CHARSET = UTF8MB4 AS
    SELECT m.concept_id AS concept_id,
           m.uuid       AS concept_uuid,
           m.name       AS concept_name
    FROM mamba_dim_concept m
    WHERE concept_id IN (SELECT DISTINCT obs_value_coded
                         FROM mamba_z_encounter_obs
                         WHERE obs_value_coded IS NOT NULL);

    CREATE INDEX mamba_idx_concept_id ON mamba_temp_value_coded_values (concept_id);

    -- Step 2: Get the maximum obs_id
    SELECT MAX(obs_id) INTO last_obs_id FROM mamba_z_encounter_obs;

    -- Step 3: Perform batch updates in a loop
    WHILE batch_last_obs_id < last_obs_id
        DO
            START TRANSACTION;

            -- Step 4: Insert relevant rows into a temporary batch table
            CREATE TEMPORARY TABLE IF NOT EXISTS mamba_temp_batch AS
            SELECT z.obs_id, mtv.concept_name, mtv.concept_uuid
            FROM mamba_z_encounter_obs z
                     INNER JOIN mamba_temp_value_coded_values mtv
                                ON z.obs_value_coded = mtv.concept_id
            WHERE z.obs_id > batch_last_obs_id
              AND z.obs_id <= batch_last_obs_id + batch_size;

            -- Step 5: Update the main table using the temporary batch table
            UPDATE mamba_z_encounter_obs z
                INNER JOIN mamba_temp_batch b
                ON z.obs_id = b.obs_id
            SET z.obs_value_text       = b.concept_name,
                z.obs_value_coded_uuid = b.concept_uuid
            WHERE 1;
            COMMIT;

            -- Step 6: Move to the next batch
            SET batch_last_obs_id = batch_last_obs_id + batch_size;
            -- Increment to next batch

            -- Drop the temporary batch table after processing
            DROP TEMPORARY TABLE IF EXISTS mamba_temp_batch;

        END WHILE;

    -- Step 7: Update obs_value_boolean using efficient filtering
    UPDATE mamba_z_encounter_obs z
    SET obs_value_boolean =
            CASE
                WHEN obs_value_text IN ('FALSE', 'No') THEN 0
                WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
                ELSE NULL
                END
    WHERE z.obs_value_coded IS NOT NULL
      AND z.obs_value_boolean IS NULL -- Only update if value is NULL to reduce update scope
      AND obs_question_concept_id IN
          (SELECT DISTINCT concept_id
           FROM mamba_dim_concept c
           WHERE c.datatype = 'Boolean');

    -- Step 8: Drop the temp table after all updates
    DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;

END //

DELIMITER ;