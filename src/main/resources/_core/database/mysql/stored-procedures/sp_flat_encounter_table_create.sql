DELIMITER //

DROP PROCEDURE IF EXISTS sp_flat_encounter_table_create;

CREATE PROCEDURE sp_flat_encounter_table_create(
    IN flat_encounter_table_name VARCHAR(255)
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @column_labels := NULL;

    SET @drop_table = CONCAT('DROP TABLE IF EXISTS `', flat_encounter_table_name, '`');

    SELECT GROUP_CONCAT(column_label SEPARATOR ' TEXT, ') INTO @column_labels
                     FROM mamba_dim_concept_metadata
                     WHERE flat_table_name = flat_encounter_table_name;

    SET @create_table = CONCAT(
            'CREATE TABLE `', flat_encounter_table_name ,'` (encounter_id INT, client_id INT, ', @column_labels, ' TEXT);');

    PREPARE deletetb FROM @drop_table;
    PREPARE createtb FROM @create_table;

    EXECUTE deletetb;
    EXECUTE createtb;

    DEALLOCATE PREPARE deletetb;
    DEALLOCATE PREPARE createtb;

END //

DELIMITER ;