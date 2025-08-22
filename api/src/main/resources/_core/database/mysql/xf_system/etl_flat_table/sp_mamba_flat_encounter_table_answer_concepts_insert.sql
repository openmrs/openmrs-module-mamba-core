DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_answer_concepts_insert;

DELIMITER //

-- Create a stored procedure to insert answer concepts into a flat table
-- These are concepts that are answers to other question concepts. e.g. multichoice answers in a select or dropdown or radio answers
-- e.g. Key population. They are usually represented as Yes/No or 1/0 or just their concept name under their column name.
-- they dont have a concept_id value or entry in the Obs table, that's why we join on o.obs_value_coded_uuid
CREATE PROCEDURE sp_mamba_flat_encounter_table_answer_concepts_insert(
    IN p_table_name VARCHAR(60),
    IN p_encounter_id INT,
    IN p_encounter_type_uuid CHAR(38),
    IN p_column_labels TEXT
)
BEGIN
    DECLARE sql_stmt TEXT;
    DECLARE update_columns TEXT;

    -- Generate UPDATE part for ON DUPLICATE KEY UPDATE
    SELECT GROUP_CONCAT(
                   CONCAT('`', column_label, '` = COALESCE(VALUES(`',
                          column_label, '`), `', column_label, '`)')
           )
    INTO update_columns
    FROM temp_concept_metadata;

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
            ON tcm.concept_uuid = o.obs_value_coded_uuid
        WHERE 1=1 '
                   );

    -- Add encounter_id filter if provided
    IF p_encounter_id IS NOT NULL THEN
        SET sql_stmt = CONCAT(sql_stmt,
                              ' AND o.encounter_id = ', p_encounter_id);
    END IF;

    -- Add remaining conditions and ON DUPLICATE KEY UPDATE clause
    SET sql_stmt = CONCAT(sql_stmt,
                          ' AND o.encounter_type_uuid = ''', p_encounter_type_uuid, '''
          AND tcm.obs_value_column IS NOT NULL
          AND o.obs_group_id IS NULL
          AND o.voided = 0
        GROUP BY o.encounter_id, o.person_id, o.encounter_datetime
        ORDER BY o.encounter_id ASC
        ON DUPLICATE KEY UPDATE ', update_columns);

    -- Execute the statement
    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;