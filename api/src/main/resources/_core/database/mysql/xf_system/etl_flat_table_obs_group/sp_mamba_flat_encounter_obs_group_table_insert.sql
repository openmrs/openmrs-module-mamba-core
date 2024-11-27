
DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_insert;

CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_insert(
    IN flat_encounter_table_name VARCHAR(60) CHARACTER SET UTF8MB4,
    IN obs_group_concept_name VARCHAR(255) CHARACTER SET UTF8MB4,
    IN encounter_id INT -- Optional parameter for incremental insert
)
BEGIN
    -- Set maximum length for GROUP_CONCAT
SET session group_concat_max_len = 20000;

-- Set up table name and encounter_id variables
SET @tbl_name = flat_encounter_table_name;
    SET @obs_group_name = obs_group_concept_name;
    SET @enc_id = encounter_id;

    -- Generate observation group table name dynamically
    SET @tbl_obs_group_name = CONCAT(LEFT(@tbl_name, 50), '_', obs_group_concept_name);

    -- Handle the optional encounter_id parameter
    IF @enc_id IS NOT NULL THEN
        -- If encounter_id is provided, delete existing records for that encounter_id
        SET @delete_stmt = CONCAT('DELETE FROM `', @tbl_obs_group_name, '` WHERE `encounter_id` = ', @enc_id);
PREPARE deletetbl FROM @delete_stmt;
EXECUTE deletetbl;
DEALLOCATE PREPARE deletetbl;
ELSE
        SET @enc_id = 0;
END IF;

    -- Create and populate a temporary table for concept metadata
    CREATE TEMPORARY TABLE IF NOT EXISTS `mamba_temp_concept_metadata_group` (
        `id` INT NOT NULL,
        `flat_table_name` VARCHAR(60) NOT NULL,
        `encounter_type_uuid` CHAR(38) NOT NULL,
        `column_label` VARCHAR(255) NOT NULL,
        `concept_uuid` CHAR(38) NOT NULL,
        `obs_value_column` VARCHAR(50),
        `concept_answer_obs` INT,
        INDEX (`id`),
        INDEX (`column_label`),
        INDEX (`concept_uuid`),
        INDEX (`concept_answer_obs`),
        INDEX (`flat_table_name`),
        INDEX (`encounter_type_uuid`)
    ) CHARSET = UTF8MB4;

TRUNCATE TABLE `mamba_temp_concept_metadata_group`;

INSERT INTO `mamba_temp_concept_metadata_group`
SELECT DISTINCT
    cm.`id`,
    cm.`flat_table_name`,
    cm.`encounter_type_uuid`,
    cm.`column_label`,
    cm.`concept_uuid`,
    fn_mamba_get_obs_value_column(cm.`concept_datatype`) AS `obs_value_column`,
    cm.`concept_answer_obs`
FROM `mamba_concept_metadata` cm
         INNER JOIN (
    SELECT DISTINCT eo.`obs_question_concept_id`
    FROM `mamba_z_encounter_obs` eo
             INNER JOIN `mamba_obs_group` og ON eo.`obs_id` = og.`obs_id`
    WHERE og.`obs_group_concept_name` = @obs_group_name
) eo ON cm.`concept_id` = eo.`obs_question_concept_id`
WHERE cm.`flat_table_name` = @tbl_name;

-- Generate dynamic column labels for the insert statement
SELECT GROUP_CONCAT(DISTINCT
                            CONCAT('MAX(CASE WHEN `column_label` = ''', `column_label`, ''' THEN ',
                                   `obs_value_column`, ' END) `', `column_label`, '`')
                            ORDER BY `id` ASC)
INTO @column_labels
FROM `mamba_temp_concept_metadata_group`;

SELECT DISTINCT `encounter_type_uuid` INTO @tbl_encounter_type_uuid FROM `mamba_temp_concept_metadata_group`;

-- Check if column labels are generated
IF @column_labels IS NOT NULL THEN

    SET @insert_stmt = CONCAT(
            'INSERT INTO `', @tbl_obs_group_name, '` ',
            'SELECT eo.`encounter_id`, MAX(eo.`visit_id`) AS `visit_id`, eo.`person_id`, eo.`encounter_datetime`, MAX(eo.`location_id`) AS `location_id`, ',
            @column_labels, ' ',
            'FROM `mamba_z_encounter_obs` eo ',
            'INNER JOIN `mamba_temp_concept_metadata_group` tcm ON tcm.`concept_uuid` = eo.`obs_question_uuid` ',
            'WHERE eo.`obs_group_id` IS NOT NULL ',
            'AND eo.`voided` = 0 ',
            IF(@enc_id <> 0, CONCAT('AND eo.`encounter_id` = ', @enc_id, ' '), ''),
            'GROUP BY eo.`encounter_id`, eo.`person_id`, eo.`encounter_datetime`, eo.`obs_group_id` '
        );

PREPARE inserttbl FROM @insert_stmt;
EXECUTE inserttbl;
DEALLOCATE PREPARE inserttbl;

SET @update_stmt = (
            SELECT GROUP_CONCAT(
                CONCAT('`', `column_label`, '` = COALESCE(VALUES(`', `column_label`, '`), `', `column_label`, '`)')
            )
            FROM `mamba_temp_concept_metadata_group`
        );

        SET @insert_stmt = CONCAT(
            'INSERT INTO `', @tbl_obs_group_name, '` ',
            'SELECT eo.`encounter_id`, MAX(eo.`visit_id`) AS `visit_id`, eo.`person_id`, eo.`encounter_datetime`, MAX(eo.`location_id`) AS `location_id`, ',
            @column_labels, ' ',
            'FROM `mamba_z_encounter_obs` eo ',
            'INNER JOIN `mamba_temp_concept_metadata_group` tcm ON tcm.`concept_uuid` = eo.`obs_value_coded_uuid` ',
            'WHERE eo.`obs_group_id` IS NOT NULL ',
            'AND eo.`voided` = 0 ',
            IF(@enc_id <> 0, CONCAT('AND eo.`encounter_id` = ', @enc_id, ' '), ''),
            'GROUP BY eo.`encounter_id`, eo.`person_id`, eo.`encounter_datetime`, eo.`obs_group_id` ',
            'ON DUPLICATE KEY UPDATE ', @update_stmt
        );

PREPARE inserttbl FROM @insert_stmt;
EXECUTE inserttbl;
DEALLOCATE PREPARE inserttbl;
END IF;

END //

DELIMITER ;
