DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_create;

CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_create(
    IN flat_encounter_table_name VARCHAR(60) CHARSET UTF8MB4,
    obs_group_name VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @column_labels := NULL;
    SET @tbl_obs_group_name = CONCAT(flat_encounter_table_name, '_', obs_group_name);

    SET @drop_table = CONCAT('DROP TABLE IF EXISTS `', @tbl_obs_group_name, '`');

    SELECT GROUP_CONCAT(CONCAT(column_label, ' ', fn_mamba_get_datatype_for_concept(concept_datatype)) SEPARATOR ', ')
    INTO @column_labels
    FROM mamba_concept_metadata cm
             INNER JOIN
         (SELECT DISTINCT obs_question_concept_id
          FROM mamba_z_encounter_obs eo
                   INNER JOIN mamba_dim_obs_group og
                              on eo.obs_group_id = og.obs_id
          WHERE obs_group_id IS NOT NULL
            AND og.obs_group_name = obs_group_name) eo
         ON cm.concept_id = eo.obs_question_concept_id
    WHERE flat_table_name = flat_encounter_table_name
      AND concept_datatype IS NOT NULL;

    IF @column_labels IS NOT NULL THEN
        SET @create_table = CONCAT(
                'CREATE TABLE `', @tbl_obs_group_name,
                '` (encounter_id INT NOT NULL, visit_id INT NULL, client_id INT NOT NULL, encounter_datetime DATETIME NOT NULL, location_id INT NULL, ',
                @column_labels,
                ', INDEX mamba_idx_encounter_id (encounter_id), INDEX mamba_idx_visit_id (visit_id), INDEX mamba_idx_client_id (client_id), INDEX mamba_idx_encounter_datetime (encounter_datetime), INDEX mamba_idx_location_id (location_id));');
    END IF;

    IF @column_labels IS NOT NULL THEN
        PREPARE deletetb FROM @drop_table;
        PREPARE createtb FROM @create_table;

        EXECUTE deletetb;
        EXECUTE createtb;

        DEALLOCATE PREPARE deletetb;
        DEALLOCATE PREPARE createtb;
    END IF;

END //

DELIMITER ;