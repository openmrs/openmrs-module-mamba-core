DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_insert_all;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_insert_all()
BEGIN
    DECLARE tbl_name VARCHAR(60);
    DECLARE obs_name VARCHAR(255);
    DECLARE done INT DEFAULT FALSE;

    -- Use a single JOINed cursor to avoid O(N*M) nested loops.
    -- This only iterates over combinations that actually exist in metadata.
    DECLARE cursor_combinations CURSOR FOR
    SELECT DISTINCT cm.flat_table_name, og.obs_group_concept_name
    FROM mamba_concept_metadata cm
    INNER JOIN mamba_z_encounter_obs eo ON cm.concept_uuid = eo.obs_question_uuid
    INNER JOIN mamba_obs_group og ON eo.obs_id = og.obs_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_combinations;
    
    combinations_loop: LOOP
        FETCH cursor_combinations INTO tbl_name, obs_name;
        IF done THEN
            LEAVE combinations_loop;
        END IF;

        CALL sp_mamba_flat_encounter_obs_group_table_insert(tbl_name, obs_name, NULL);
    END LOOP;

    CLOSE cursor_combinations;

END //

DELIMITER ;