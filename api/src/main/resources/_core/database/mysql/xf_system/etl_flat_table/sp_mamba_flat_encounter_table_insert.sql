DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert;

DELIMITER //

-- NOTE: this script was merged with the sp_mamba_flat_table_obs_incremental_insert script
-- NOTE: ONLY difference was the filter  WHERE o.encounter_id = ''', @enc_id, '''
-- NOTE: Here we were only inserting all obs/encounters for this flat table
-- NOTE: Where as in the sp_mamba_flat_table_obs_incremental_insert we were only updating the encounter in the flat table that has changes

CREATE PROCEDURE sp_mamba_flat_encounter_table_insert(
    IN `flat_encounter_table_name` VARCHAR(60) CHARACTER SET UTF8MB4,
    IN encounter_id INT -- Optional parameter for incremental insert
)
BEGIN
    SET session group_concat_max_len = 20000;
    SET @tbl_name = `flat_encounter_table_name`;
    SET @enc_id = encounter_id;

    -- called outside the incremental script
    -- Handle the optional encounter_id parameter by setting a default value if NULL
    IF @enc_id IS NULL THEN
        SET @enc_id = 0;
    ELSE
        -- called through the incremental script
        -- if enc_id exits in the table @tbl_name, then delete the record (to be replaced with the new one)
        SET @delete_stmt = CONCAT('DELETE FROM `', @tbl_name, '` WHERE `encounter_id` = ', @enc_id);
        PREPARE `deletetb` FROM @delete_stmt;
        EXECUTE `deletetb`;
        DEALLOCATE PREPARE `deletetb`;
    END IF;

    -- Precompute the concept metadata table to minimize repeated queries
    CREATE TEMPORARY TABLE IF NOT EXISTS `mamba_temp_concept_metadata`
    (
        `id`                  INT          NOT NULL,
        `flat_table_name`     VARCHAR(60)  NOT NULL,
        `encounter_type_uuid` CHAR(38)     NOT NULL,
        `column_label`        VARCHAR(255) NOT NULL,
        `concept_uuid`        CHAR(38)     NOT NULL,
        `obs_value_column`    VARCHAR(50),
        `concept_datatype`    VARCHAR(50),
        `concept_answer_obs`  INT,

        INDEX `mamba_idx_id` (`id`),
        INDEX `mamba_idx_column_label` (`column_label`),
        INDEX `mamba_idx_concept_uuid` (`concept_uuid`),
        INDEX `mamba_idx_concept_answer_obs` (`concept_answer_obs`),
        INDEX `mamba_idx_flat_table_name` (`flat_table_name`),
        INDEX `mamba_idx_encounter_type_uuid` (`encounter_type_uuid`)
    )
        CHARSET = UTF8MB4;

    TRUNCATE TABLE `mamba_temp_concept_metadata`;

    INSERT INTO `mamba_temp_concept_metadata`
    SELECT DISTINCT `id`,
                    `flat_table_name`,
                    `encounter_type_uuid`,
                    `column_label`,
                    `concept_uuid`,
                    fn_mamba_get_obs_value_column(`concept_datatype`) AS `obs_value_column`,
                    `concept_datatype`,
                    `concept_answer_obs`
    FROM `mamba_concept_metadata`
    WHERE `flat_table_name` = @tbl_name
      AND `concept_id` IS NOT NULL
      AND `concept_datatype` IS NOT NULL;

    SELECT GROUP_CONCAT(DISTINCT
                        CONCAT('MAX(CASE WHEN `column_label` = ''', `column_label`, ''' THEN ',
                               `obs_value_column`, ' END) `', `column_label`, '`')
                        ORDER BY `id` ASC)
    INTO @column_labels
    FROM `mamba_temp_concept_metadata`;

    SELECT DISTINCT `encounter_type_uuid` INTO @tbl_encounter_type_uuid FROM `mamba_temp_concept_metadata`;

    IF @column_labels IS NOT NULL THEN
        -- First Insert: `concept_answer_obs` = 0 OR 2
        SET @insert_stmt = CONCAT(
                'INSERT INTO `', @tbl_name,
                '` SELECT `o`.`encounter_id`, MAX(`o`.`visit_id`) AS `visit_id`, `o`.`person_id`, `o`.`encounter_datetime`, MAX(`o`.`location_id`) AS `location_id`, ',
                @column_labels, '
                FROM `mamba_z_encounter_obs` `o`
                    INNER JOIN `mamba_temp_concept_metadata` `tcm`
                    ON `tcm`.`concept_uuid` = `o`.`obs_question_uuid`
                WHERE 1=1 ',
                IF(@enc_id <> 0, CONCAT('AND `o`.`encounter_id` = ', @enc_id), ''),
                ' AND `o`.`encounter_type_uuid` = ''', @tbl_encounter_type_uuid, '''
                AND (`tcm`.`concept_answer_obs` = 0 OR `tcm`.`concept_datatype` != ''Coded'')
                AND `tcm`.`obs_value_column` IS NOT NULL
                AND `o`.`obs_group_id` IS NULL AND `o`.`voided` = 0
                GROUP BY `o`.`encounter_id`, `o`.`person_id`, `o`.`encounter_datetime`
                ORDER BY `o`.`encounter_id` ASC');

        PREPARE `inserttbl` FROM @insert_stmt;
        EXECUTE `inserttbl`;
        DEALLOCATE PREPARE `inserttbl`;

        -- Second Insert: `concept_answer_obs` = 1 OR 2, Handle potential duplicates
        SET @update_stmt =
                (SELECT GROUP_CONCAT(CONCAT('`', `column_label`, '` = COALESCE(VALUES(`', `column_label`, '`), `',
                                            `column_label`, '`)'))
                 FROM `mamba_temp_concept_metadata`);


        SET @insert_stmt = CONCAT(
                'INSERT INTO `', @tbl_name,
                '` SELECT `o`.`encounter_id`, MAX(`o`.`visit_id`) AS `visit_id`, `o`.`person_id`, `o`.`encounter_datetime`, MAX(`o`.`location_id`) AS `location_id`, ',
                @column_labels, '
                FROM `mamba_z_encounter_obs` `o`
                    INNER JOIN `mamba_temp_concept_metadata` `tcm`
                    ON `tcm`.`concept_uuid` = `o`.`obs_value_coded_uuid`
                WHERE 1=1 ',
                IF(@enc_id <> 0, CONCAT('AND `o`.`encounter_id` = ', @enc_id), ''),
                ' AND `o`.`encounter_type_uuid` = ''', @tbl_encounter_type_uuid, '''
                AND (`tcm`.`concept_answer_obs` = 1 OR `tcm`.`concept_answer_obs` = 2)
                AND `tcm`.`obs_value_column` IS NOT NULL
                AND `o`.`obs_group_id` IS NULL AND `o`.`voided` = 0
                GROUP BY `o`.`encounter_id`, `o`.`person_id`, `o`.`encounter_datetime`
                ORDER BY `o`.`encounter_id` ASC
                ON DUPLICATE KEY UPDATE ', @update_stmt);

        PREPARE `inserttbl` FROM @insert_stmt;
        EXECUTE `inserttbl`;
        DEALLOCATE PREPARE `inserttbl`;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS `mamba_temp_concept_metadata`;

END //

DELIMITER ;