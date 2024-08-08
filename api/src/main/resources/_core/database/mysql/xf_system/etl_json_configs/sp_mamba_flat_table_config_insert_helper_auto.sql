-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_insert_helper_auto;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_table_config_insert_helper_auto()
main_block:
BEGIN

    DECLARE encounter_type_name CHAR(50) CHARACTER SET UTF8MB4;
    DECLARE is_automatic_flattening TINYINT(1);

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_encounter_type_name CURSOR FOR
        SELECT DISTINCT et.name
        FROM mamba_source_db.obs o
                 INNER JOIN mamba_source_db.encounter e ON e.encounter_id = o.encounter_id
                 INNER JOIN mamba_dim_encounter_type et ON e.encounter_type = et.encounter_type_id
        WHERE et.encounter_type_id NOT IN (SELECT DISTINCT tc.encounter_type_id from mamba_flat_table_config tc)
          AND et.retired = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT DISTINCT(automatic_flattening_mode_switch)
    INTO is_automatic_flattening
    FROM _mamba_etl_user_settings;

    -- If auto-flattening is not switched on, do nothing
    IF is_automatic_flattening = 0 THEN
        LEAVE main_block;
    END IF;

    OPEN cursor_encounter_type_name;
    computations_loop:
    LOOP
        FETCH cursor_encounter_type_name INTO encounter_type_name;

        IF done THEN
            LEAVE computations_loop;
        END IF;

        SET @insert_stmt = CONCAT(
                'INSERT INTO mamba_flat_table_config(report_name, encounter_type_id, table_json_data, encounter_type_uuid)
                    SELECT
                        name,
                        encounter_type_id,
                         CONCAT(''{'',
                            ''"report_name": "'', name, ''", '',
                            ''"flat_table_name": "'', table_name, ''", '',
                            ''"encounter_type_uuid": "'', uuid, ''", '',
                            ''"table_columns": '', json_obj, '' '',
                            ''}'') AS table_json_data,
                        encounter_type_uuid
                    FROM (
                        SELECT DISTINCT
                            et.name,
                            encounter_type_id,
                            et.auto_flat_table_name AS table_name,
                            et.uuid, ',
                '(
                SELECT DISTINCT CONCAT(''{'', GROUP_CONCAT(CONCAT(''"'', name, ''":"'', uuid, ''"'') SEPARATOR '','' ),''}'') x
                FROM (
                        SELECT
                            DISTINCT et.encounter_type_id,
                            c.auto_table_column_name AS name,
                            c.uuid
                        FROM mamba_source_db.obs o
                        INNER JOIN mamba_source_db.encounter e
                                  ON e.encounter_id = o.encounter_id
                        INNER JOIN mamba_dim_encounter_type et
                                  ON e.encounter_type = et.encounter_type_id
                        INNER JOIN mamba_dim_concept c
                                  ON o.concept_id = c.concept_id
                        WHERE et.name = ''', encounter_type_name, '''
                                    AND et.retired = 0
                                ) json_obj
                        ) json_obj,
                       et.uuid as encounter_type_uuid
                    FROM mamba_dim_encounter_type et
                    INNER JOIN mamba_source_db.encounter e
                        ON e.encounter_type = et.encounter_type_id
                    WHERE et.name = ''', encounter_type_name, '''
                ) X  ;   ');
        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;
    END LOOP computations_loop;
    CLOSE cursor_encounter_type_name;

END //

DELIMITER ;