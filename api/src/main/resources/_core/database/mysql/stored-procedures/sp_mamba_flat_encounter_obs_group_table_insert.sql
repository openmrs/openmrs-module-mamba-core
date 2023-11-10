DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_insert;

CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_insert(
    IN flat_encounter_table_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @tbl_name = flat_encounter_table_name;
    SET @tbl_obs_group_name = CONCAT(@tbl_name,'_obs_group');

        SET @old_sql = (SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR ', ')
                        FROM INFORMATION_SCHEMA.COLUMNS
                        WHERE TABLE_NAME = @tbl_name
                          AND TABLE_SCHEMA = Database());

    SELECT
        GROUP_CONCAT(DISTINCT
                CONCAT(' MAX(CASE WHEN column_label = ''', column_label, ''' THEN ',
                    fn_mamba_get_obs_value_column(concept_datatype), ' END) ', column_label)
                ORDER BY id ASC)
    INTO @column_labels
    FROM mamba_dim_concept_metadata cm
             INNER JOIN
         (
             SELECT
                 DISTINCT obs_question_concept_id
             FROM  mamba_z_encounter_obs
             WHERE obs_group_id IS NOT NULL
         ) eo
         ON cm.concept_id = eo.obs_question_concept_id
    WHERE flat_table_name = @tbl_name;

    IF @column_labels IS NOT NULL THEN
            IF (SELECT count(*)FROM information_schema.tables WHERE table_name = @tbl_obs_group_name) > 0 THEN
                SET @insert_stmt = CONCAT(
                        'INSERT INTO `', @tbl_obs_group_name, '` SELECT eo.encounter_id, eo.person_id, eo.encounter_datetime, ',
                        @column_labels, '
                        FROM mamba_z_encounter_obs eo
                            INNER JOIN mamba_dim_concept_metadata cm
                            ON IF(cm.concept_answer_obs=1, cm.concept_uuid=eo.obs_value_coded_uuid, cm.concept_uuid=eo.obs_question_uuid)
                        WHERE  cm.flat_table_name = ''', @tbl_name, '''
                        AND eo.encounter_type_uuid = cm.encounter_type_uuid
                        AND eo.obs_group_id IS NOT NULL
                        GROUP BY eo.encounter_id, eo.person_id, eo.encounter_datetime,eo.obs_group_id;');
    END IF;
    END IF;

        IF @column_labels IS NOT NULL THEN
            PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;
    END IF;

END //

DELIMITER ;