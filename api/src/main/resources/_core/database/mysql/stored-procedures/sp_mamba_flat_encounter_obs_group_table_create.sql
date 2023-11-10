DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_obs_group_table_create;

CREATE PROCEDURE sp_mamba_flat_encounter_obs_group_table_create(
    IN flat_encounter_table_name VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @column_labels := NULL;
    SET @tbl_obs_group_name = CONCAT(flat_encounter_table_name,'_obs_group');

    SET @drop_table = CONCAT('DROP TABLE IF EXISTS `', @tbl_obs_group_name, '`');

    SELECT GROUP_CONCAT(column_label SEPARATOR ' TEXT, ')
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
    WHERE flat_table_name = flat_encounter_table_name
      AND concept_datatype IS NOT NULL;

    IF @column_labels IS NOT NULL THEN
        SET @create_table = CONCAT(
                'CREATE TABLE `', @tbl_obs_group_name, '` (encounter_id INT NOT NULL, client_id INT NOT NULL, encounter_datetime DATETIME NOT NULL, ', @column_labels, ' TEXT, INDEX idx_encounter_id (encounter_id), INDEX idx_client_id (client_id), INDEX idx_encounter_datetime (encounter_datetime));');
    END IF;


    PREPARE deletetb FROM @drop_table;
    PREPARE createtb FROM @create_table;

    EXECUTE deletetb;
    IF @column_labels IS NOT NULL THEN
        EXECUTE createtb;
    END IF;

    DEALLOCATE PREPARE deletetb;
    DEALLOCATE PREPARE createtb;

END //

DELIMITER ;