DELIMITER //

DROP PROCEDURE IF EXISTS `sp_mamba_flat_encounter_obs_group_table_insert`;

CREATE PROCEDURE `sp_mamba_flat_encounter_obs_group_table_insert`(
    IN `flat_encounter_table_name` VARCHAR(60) CHARACTER SET UTF8MB4,
    `obs_group_concept_name` VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @tbl_name = `flat_encounter_table_name`;

        SET @tbl_obs_group_name = CONCAT(LEFT(@tbl_name, 50), '_', `obs_group_concept_name`); -- TODO: 50 + 12 to make 62

        SET @old_sql = (SELECT GROUP_CONCAT(`COLUMN_NAME` SEPARATOR ', ')
                        FROM `INFORMATION_SCHEMA`.`COLUMNS`
                        WHERE `TABLE_NAME` = @tbl_name
                          AND `TABLE_SCHEMA` = DATABASE());

    SELECT GROUP_CONCAT(DISTINCT
                            CONCAT(' MAX(CASE WHEN `column_label` = ''', `column_label`, ''' THEN ',
                                   fn_mamba_get_obs_value_column(`concept_datatype`), ' END) ', `column_label`)
                            ORDER BY `id` ASC)
    INTO @column_labels
    FROM `mamba_concept_metadata` `cm`
             INNER JOIN
         (SELECT DISTINCT `obs_question_concept_id`
          FROM `mamba_z_encounter_obs` `eo`
                   INNER JOIN `mamba_obs_group` `og`
                              ON `eo`.`obs_id` = `og`.`obs_id`
          WHERE `obs_group_id` IS NOT NULL
            AND `og`.`obs_group_concept_name` = `obs_group_concept_name`) `eo`
         ON `cm`.`concept_id` = `eo`.`obs_question_concept_id`
    WHERE `flat_table_name` = @tbl_name;

    IF @column_labels IS NOT NULL THEN
            IF (SELECT COUNT(*) FROM `information_schema`.`tables` WHERE `table_name` = @tbl_obs_group_name) > 0 THEN
                SET @insert_stmt = CONCAT(
                        'INSERT INTO `', @tbl_obs_group_name,
                        '` SELECT `eo`.`encounter_id`, MAX(`eo`.`visit_id`) AS `visit_id`, `eo`.`person_id`, `eo`.`encounter_datetime`, MAX(`eo`.`location_id`) AS `location_id`, ',
                        @column_labels, '
                        FROM `mamba_z_encounter_obs` `eo`
                            INNER JOIN `mamba_concept_metadata` `cm`
                            ON IF(`cm`.`concept_answer_obs`=1, `cm`.`concept_uuid`=`eo`.`obs_value_coded_uuid`, `cm`.`concept_uuid`=`eo`.`obs_question_uuid`)
                        WHERE  `cm`.`flat_table_name` = ''', @tbl_name, '''
                        AND `eo`.`encounter_type_uuid` = `cm`.`encounter_type_uuid`
                        AND `eo`.`obs_group_id` IS NOT NULL
                        GROUP BY `eo`.`encounter_id`, `eo`.`person_id`, `eo`.`encounter_datetime`, `eo`.`obs_group_id`;');
    END IF;
    END IF;

        IF @column_labels IS NOT NULL THEN
            PREPARE `inserttbl` FROM @insert_stmt;
    EXECUTE `inserttbl`;
    DEALLOCATE PREPARE `inserttbl`;
    END IF;

END //

DELIMITER ;