DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_encounter_table_insert(
    IN p_flat_table_name VARCHAR(60) CHARACTER SET UTF8MB4,
    IN p_encounter_id INT -- Optional parameter for incremental insert
)
BEGIN

    DROP TEMPORARY TABLE IF EXISTS temp_concept_metadata;

    SET session group_concat_max_len = 20000;

    -- Handle incremental updates
    IF p_encounter_id IS NOT NULL THEN
        -- Delete existing record for the encounter
        SET @delete_stmt = CONCAT('DELETE FROM `', p_flat_table_name, '` WHERE `encounter_id` = ?');
        PREPARE stmt FROM @delete_stmt;
        SET @encounter_id = p_encounter_id;  -- Bind the variable
        EXECUTE stmt USING @encounter_id;     -- Use the bound variable
        DEALLOCATE PREPARE stmt;
    END IF;

    -- Create and populate temporary metadata table
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_concept_metadata
    (
        `id`                  INT          NOT NULL,
        `flat_table_name`     VARCHAR(60)  NOT NULL,
        `encounter_type_uuid` CHAR(38)     NOT NULL,
        `column_label`        VARCHAR(255) NOT NULL,
        `concept_uuid`        CHAR(38)     NOT NULL,
        `obs_value_column`    VARCHAR(50),
        `concept_datatype`    VARCHAR(50),
        `concept_answer_obs`  INT,

        INDEX idx_id (`id`),
        INDEX idx_column_label (`column_label`),
        INDEX idx_concept_uuid (`concept_uuid`),
        INDEX idx_concept_answer_obs (`concept_answer_obs`),
        INDEX idx_flat_table_name (`flat_table_name`),
        INDEX idx_encounter_type_uuid (`encounter_type_uuid`)
    ) CHARSET = UTF8MB4;

    -- Populate metadata
    INSERT INTO temp_concept_metadata
    SELECT DISTINCT `id`,
                    `flat_table_name`,
                    `encounter_type_uuid`,
                    `column_label`,
                    `concept_uuid`,
                    fn_mamba_get_obs_value_column(`concept_datatype`),
                    `concept_datatype`,
                    `concept_answer_obs`
    FROM `mamba_concept_metadata`
    WHERE `flat_table_name` = p_flat_table_name
      AND `concept_id` IS NOT NULL
      AND `concept_datatype` IS NOT NULL;

    -- Generate dynamic columns
    SELECT GROUP_CONCAT(
                   DISTINCT CONCAT(
                    'MAX(CASE WHEN `column_label` = ''',
                    `column_label`,
                    ''' THEN ',
                    `obs_value_column`,
                    ' END) `',
                    `column_label`,
                    '`'
                            ) ORDER BY `id` ASC
           )
    INTO @column_labels
    FROM temp_concept_metadata;

    -- Get encounter type UUID
    SELECT DISTINCT `encounter_type_uuid`
    INTO @encounter_type_uuid
    FROM temp_concept_metadata
    LIMIT 1;

    -- Process data if columns exist
    IF @column_labels IS NOT NULL THEN
        -- Handle non-coded concepts first
        CALL sp_mamba_flat_encounter_table_non_coded_concepts_insert(
                p_flat_table_name,
                p_encounter_id,
                @encounter_type_uuid,
                @column_labels
             );

        -- Handle coded concepts
        CALL sp_mamba_flat_encounter_table_coded_concepts_insert(
                p_flat_table_name,
                p_encounter_id,
                @encounter_type_uuid,
                @column_labels
             );
    END IF;

END //

DELIMITER ;