-- Flatten all Encounters given in Config folder
DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_insert_all;

CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_insert_all()
BEGIN

    DECLARE tbl_name VARCHAR(60) CHARACTER SET UTF8MB4;
    DECLARE obs_name CHAR(50) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT 0;

    DECLARE cursor_flat_tables CURSOR FOR
    SELECT DISTINCT(flat_table_name) FROM mamba_concept_metadata;

    DECLARE cursor_obs_group_tables CURSOR FOR
    SELECT DISTINCT(obs_group_name) FROM mamba_dim_obs_group;

    -- DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor_flat_tables;

        REPEAT
            FETCH cursor_flat_tables INTO tbl_name;
                IF NOT done THEN
                    OPEN cursor_obs_group_tables;
                        block2: BEGIN
                            DECLARE doneobs_name INT DEFAULT 0;
                            DECLARE firstobs_name varchar(255) DEFAULT '';
                            DECLARE i int DEFAULT 1;
                            DECLARE CONTINUE HANDLER FOR NOT FOUND SET doneobs_name = 1;

                            REPEAT
                                FETCH cursor_obs_group_tables INTO obs_name;

                                    IF i = 1 THEN
                                        SET firstobs_name = obs_name;
                                    END IF;

                                    CALL sp_mamba_flat_encounter_obs_group_table_insert(tbl_name,obs_name);
                                    SET i = i + 1;

                                UNTIL doneobs_name
                            END REPEAT;

                            CALL sp_mamba_flat_encounter_obs_group_table_insert(tbl_name,firstobs_name);
                        END block2;
                    CLOSE cursor_obs_group_tables;
            END IF;
                        UNTIL done
        END REPEAT;
    CLOSE cursor_flat_tables;

END //

DELIMITER ;