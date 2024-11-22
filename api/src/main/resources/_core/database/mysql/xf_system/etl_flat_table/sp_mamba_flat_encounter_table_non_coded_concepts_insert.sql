DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_non_coded_concepts_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_encounter_table_non_coded_concepts_insert(
    IN p_table_name VARCHAR(60),
    IN p_encounter_id INT,
    IN p_encounter_type_uuid CHAR(38),
    IN p_column_labels TEXT
)
BEGIN
    DECLARE sql_stmt TEXT;

    -- Construct base INSERT statement
    SET sql_stmt = CONCAT(
            'INSERT INTO `', p_table_name, '` ',
            'SELECT
                o.encounter_id,
                MAX(o.visit_id) AS visit_id,
                o.person_id,
                o.encounter_datetime,
                MAX(o.location_id) AS location_id,
                ', p_column_labels, '
        FROM mamba_z_encounter_obs o
        INNER JOIN temp_concept_metadata tcm
            ON tcm.concept_uuid = o.obs_question_uuid
        WHERE 1=1 ');

    -- Add encounter_id filter if provided
    IF p_encounter_id IS NOT NULL THEN
        SET sql_stmt = CONCAT(sql_stmt,
                              ' AND o.encounter_id = ', p_encounter_id);
    END IF;

    -- Add remaining conditions
    SET sql_stmt = CONCAT(sql_stmt,
                          ' AND o.encounter_type_uuid = ''', p_encounter_type_uuid, '''
          AND (tcm.concept_answer_obs = 0 OR tcm.concept_datatype != ''Coded'')
          AND tcm.obs_value_column IS NOT NULL
          AND o.obs_group_id IS NULL
          AND o.voided = 0
        GROUP BY o.encounter_id, o.person_id, o.encounter_datetime
        ORDER BY o.encounter_id ASC');

    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;