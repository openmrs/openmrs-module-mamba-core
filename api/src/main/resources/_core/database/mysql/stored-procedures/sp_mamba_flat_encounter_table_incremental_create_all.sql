-- Flatten all Modified or New Encounters
DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_incremental_create_all;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_encounter_table_incremental_create_all()
BEGIN

    DECLARE tbl_name CHAR(50) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_flat_tables CURSOR FOR
    SELECT DISTINCT m.flat_table_name FROM mamba_dim_json j INNER JOIN mamba_dim_concept_metadata m ON j.uuid = m.encounter_type_uuid WHERE j.flag in (1,2);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_flat_tables;
    computations_loop:
            LOOP
                FETCH cursor_flat_tables INTO tbl_name;

                IF done THEN
                    LEAVE computations_loop;
    END IF;

    CALL sp_mamba_flat_encounter_table_create(tbl_name);

    END LOOP computations_loop;
    CLOSE cursor_flat_tables;

END //

DELIMITER ;