DROP PROCEDURE IF EXISTS sp_mamba_missing_table_column_names_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_missing_table_column_names_insert()
BEGIN

    DECLARE encounter_type_uuid_value CHAR(38);
    DECLARE report_name_val VARCHAR(100);
    DECLARE encounter_type_id_val INT;
    DECLARE flat_table_name_val VARCHAR(255);
    DECLARE concepts_locale_val VARCHAR(20);

    DECLARE done INT DEFAULT FALSE;

    DECLARE cursor_encounters CURSOR FOR

        SELECT DISTINCT(encounter_type_uuid), m.report_name, m.flat_table_name, m.concepts_locale, et.encounter_type_id
        FROM mamba_dim_concept_metadata m
                 INNER JOIN mamba_source_db.encounter_type et ON m.encounter_type_uuid = et.uuid
        WHERE et.retired = 0
          AND m.concept_uuid = 'AUTO-GENERATE'
          AND m.column_label = 'AUTO-GENERATE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_encounters;
    computations_loop:
        LOOP
            FETCH cursor_encounters
                     INTO encounter_type_uuid_value, report_name_val, flat_table_name_val, concepts_locale_val, encounter_type_id_val;

            IF done THEN
                LEAVE computations_loop;
            END IF;

             SET @insert_stmt = CONCAT(
            'INSERT INTO mamba_dim_concept_metadata
            (
                report_name,
                flat_table_name,
                encounter_type_uuid,
                column_label,
                concept_uuid,
                concepts_locale
            )
            SELECT
                ''',report_name_val,''',
                ''',flat_table_name_val,''',
                ''',encounter_type_uuid_value,''',
                field_name,
                concept_uuid,
                ''',concepts_locale_val,'''
                FROM (
                     SELECT
                          DISTINCT et.encounter_type_id,
                          LOWER(LEFT(REPLACE(REPLACE(REGEXP_REPLACE(cn.name, ''[^0-9a-z]'', ''''), '' '', ''_''),''__'', ''_''),35)) field_name,
                          c.uuid AS concept_uuid
                     FROM mamba_source_db.obs o
                          INNER JOIN mamba_source_db.encounter e
                            ON e.encounter_id = o.encounter_id
                          INNER JOIN mamba_source_db.encounter_type et
                            ON e.encounter_type = et.encounter_type_id
                          INNER JOIN mamba_source_db.concept_name cn
                            ON cn.concept_id = o.concept_id
                          INNER JOIN mamba_source_db.concept c
                            ON cn.concept_id = c.concept_id
                     WHERE et.encounter_type_id = ''',encounter_type_id_val,'''
                       AND cn.locale = ''',concepts_locale_val,'''
                            AND cn.voided = 0
                            AND cn.locale_preferred = 1
                            AND et.retired = 0
                ) mamba_missing_concept;
            ');

        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;

    END LOOP computations_loop;
    CLOSE cursor_encounters;

END //

DELIMITER ;