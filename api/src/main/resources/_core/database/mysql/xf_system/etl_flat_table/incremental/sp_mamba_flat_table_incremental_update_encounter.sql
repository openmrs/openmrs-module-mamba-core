DROP PROCEDURE IF EXISTS sp_mamba_flat_table_obs_incremental_insert_all;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_table_obs_incremental_insert_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;
    DECLARE encounter_id INT;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
        SELECT DISTINCT eo.encounter_id, cm.flat_table_name
        FROM mamba_z_encounter_obs eo
                 INNER JOIN mamba_concept_metadata cm ON eo.encounter_type_uuid = cm.encounter_type_uuid
        WHERE eo.incremental_record = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
    LOOP
        FETCH cursor_flat_tables INTO encounter_id, tbl_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        CALL sp_mamba_flat_encounter_table_insert(tbl_name, encounter_id); -- Update only OBS/Encounters that have been modified for this flat table

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END //

DELIMITER ;