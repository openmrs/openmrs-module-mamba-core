-- Flatten all Encounters given in Config folder
DROP PROCEDURE IF EXISTS sp_mamba_json_files_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_json_files_insert()
BEGIN

    DECLARE json_file CHAR(50) CHARACTER SET UTF8MB4;

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_json_file CURSOR FOR
        SELECT 
            DISTINCT et.name 
        FROM mamba_source_db.obs o
        INNER JOIN mamba_source_db.encounter e ON e.encounter_id = o.encounter_id
        INNER JOIN mamba_source_db.encounter_type et ON e.encounter_type = et.encounter_type_id
        WHERE et.retired = 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_json_file;
    computations_loop:
        LOOP
            FETCH cursor_json_file INTO json_file;

            IF done THEN
                LEAVE computations_loop;
    END IF;

    SET @insert_stmt = CONCAT(
            'INSERT INTO mamba_dim_json(report_name,encounter_type_id,Json_data,uuid)
                SELECT
                    name,
                    encounter_type_id,
                    JSON_OBJECT(
                    ''report_name'',name,
                    ''flat_table_name'',table_name,
                    ''encounter_type_uuid'',uuid,
                    ''concepts_locale'',locale,
                    ''table_columns'',json_obj
                    ), encounter_type_uuid
                FROM (
                    SELECT DISTINCT
                        et.name,
                        encounter_type_id,
                        concat(''mamba_flat_encounter_'',LOWER(LEFT(REPLACE(REGEXP_REPLACE(et.name, ''[^0-9a-z]'', ''''),'' '',''''),18))) AS table_name,
                        et.uuid,
                        ''en'' AS locale,
                        (
                            SELECT
                                DISTINCT JSON_OBJECTAGG(name,uuid )x
                            FROM (
                                    SELECT
                                        DISTINCT et.encounter_type_id,
                                        LOWER(LEFT(REPLACE(REPLACE(REGEXP_REPLACE(cn.name, ''[^0-9a-z]'', ''''), '' '', ''_''),''__'', ''_''),35)) name,
                                        c.uuid
                                    FROM mamba_source_db.obs o
                                    INNER JOIN mamba_source_db.encounter e
                                              ON e.encounter_id = o.encounter_id
                                    INNER JOIN mamba_source_db.encounter_type et
                                              ON e.encounter_type = et.encounter_type_id
                                    INNER JOIN mamba_source_db.concept_name cn
                                              ON cn.concept_id = o.concept_id
                                    INNER JOIN mamba_source_db.concept c
                                              ON cn.concept_id = c.concept_id
                                    WHERE et.name = ''', json_file, '''
                                    AND cn.locale = ''en''
                                    AND cn.voided = 0
                                    AND cn.locale_preferred = 1
                                    AND et.retired = 0
                                ) json_obj
                        ) json_obj,
                       et.uuid as encounter_type_uuid
                    FROM mamba_source_db.encounter_type et
                    INNER JOIN mamba_source_db.encounter e
                        ON e.encounter_type = et.encounter_type_id
                    WHERE et.name = ''', json_file, '''
                ) X  ;   ');

        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;
    END LOOP computations_loop;
    CLOSE cursor_json_file;

END //

DELIMITER ;