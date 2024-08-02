DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_encounter_table_insert(
    IN flat_encounter_table_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @tbl_name = flat_encounter_table_name;

    SET @old_sql = (SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR ', ')
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = @tbl_name
                      AND TABLE_SCHEMA = Database());

    SELECT GROUP_CONCAT(DISTINCT
                        CONCAT(' MAX(CASE WHEN column_label = ''', column_label, ''' THEN ',
                               fn_mamba_get_obs_value_column(concept_datatype), ' END) ', column_label)
                        ORDER BY id ASC)
    INTO @column_labels
    FROM mamba_dim_concept_metadata
    WHERE flat_table_name = @tbl_name;

    IF @column_labels IS NOT NULL THEN
        SET @insert_stmt = CONCAT(
                'INSERT INTO `', @tbl_name,
                '` SELECT o.encounter_id, o.person_id, o.encounter_datetime, o.location_id, ',
                @column_labels, '
                FROM mamba_z_encounter_obs o
                    INNER JOIN mamba_dim_concept_metadata cm
                    ON IF(cm.concept_answer_obs=1, cm.concept_uuid=o.obs_value_coded_uuid, cm.concept_uuid=o.obs_question_uuid)
                WHERE cm.flat_table_name = ''', @tbl_name, '''
                AND o.encounter_type_uuid = cm.encounter_type_uuid
                AND o.row_num = cm.row_num AND o.obs_group_id IS NULL AND o.voided = 0
                GROUP BY o.encounter_id, o.person_id, o.encounter_datetime, o.location_id;');
    END IF;

    IF @column_labels IS NOT NULL THEN
        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;
    END IF;

END //

DELIMITER ;