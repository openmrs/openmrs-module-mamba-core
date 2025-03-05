DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_update;

DELIMITER //

CREATE PROCEDURE sp_mamba_z_encounter_obs_update()
BEGIN
    DECLARE total_records INT;
    DECLARE batch_size INT DEFAULT 100000; -- batch size
    DECLARE mamba_offset INT DEFAULT 0;

    CREATE TEMPORARY TABLE mamba_temp_value_coded_values
        CHARSET = UTF8MB4 AS
    SELECT m.concept_id AS concept_id,
           m.uuid       AS concept_uuid,
           m.name       AS concept_name
    FROM mamba_dim_concept m
    WHERE concept_id in (SELECT DISTINCT obs_value_coded
                         FROM mamba_z_encounter_obs
                         WHERE obs_value_coded IS NOT NULL);
    CREATE INDEX mamba_idx_concept_id ON mamba_temp_value_coded_values (concept_id);

    SELECT COUNT(*)
    INTO total_records
    FROM mamba_z_encounter_obs z
             INNER JOIN mamba_temp_value_coded_values mtv
                        ON z.obs_value_coded = mtv.concept_id
    WHERE z.obs_value_coded IS NOT NULL;

    WHILE mamba_offset < total_records
        DO
            -- update obs_value_coded (UUIDs & Concept value names)
            SET @sql = CONCAT('UPDATE mamba_z_encounter_obs z
                        INNER JOIN (
                            SELECT concept_id, concept_name, concept_uuid
                            FROM mamba_temp_value_coded_values mtv
                            ORDER BY concept_id
                            LIMIT ', batch_size, 'OFFSET', mamba_offset,'
                        ) AS mtv
                        ON z.obs_value_coded = mtv.concept_id
                        SET z.obs_value_text = mtv.concept_name,
                            z.obs_value_coded_uuid = mtv.concept_uuid
                        WHERE z.obs_value_coded IS NOT NULL');
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

            SET mamba_offset = mamba_offset + batch_size;
        END WHILE;

-- update column obs_value_boolean (Concept values)
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

    DROP TEMPORARY TABLE IF EXISTS mamba_temp_value_coded_values;

END //

DELIMITER ;