DELIMITER //

DROP PROCEDURE IF EXISTS sp_flat_encounter_table_create;

CREATE PROCEDURE sp_flat_encounter_table_create(
    IN flat_encounter_table_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @column_labels := NULL;

    SET @drop_table = CONCAT('DROP TABLE IF EXISTS `', flat_encounter_table_name, '`');

    SELECT GROUP_CONCAT(column_label SEPARATOR ' TEXT, ')
    INTO @column_labels
    FROM mamba_dim_concept_metadata
    WHERE flat_table_name = flat_encounter_table_name
      AND concept_datatype IS NOT NULL;

    IF @column_labels IS NULL THEN
        SET @create_table = CONCAT(
                'CREATE TABLE `', flat_encounter_table_name, '` (encounter_id INT, client_id INT);');
    ELSE
        SET @create_table = CONCAT(
                'CREATE TABLE `', flat_encounter_table_name, '` (encounter_id INT, client_id INT, ', @column_labels,
                ' TEXT);');
    END IF;

    SET @create_enc_id_index =
            CONCAT('CREATE INDEX mamba_flat_encounter_id ON `', flat_encounter_table_name, '` (encounter_id);');

    SET @create_client_id_index =
            CONCAT('CREATE INDEX mamba_flat_client_id ON `', flat_encounter_table_name, '` (client_id);');


    PREPARE deletetb FROM @drop_table;
    PREPARE createtb FROM @create_table;
    PREPARE createencididx FROM @create_enc_id_index;
    PREPARE createclientididx FROM @create_client_id_index;

    EXECUTE deletetb;
    EXECUTE createtb;
    EXECUTE createencididx;
    EXECUTE createclientididx;

    DEALLOCATE PREPARE deletetb;
    DEALLOCATE PREPARE createtb;
    DEALLOCATE PREPARE createencididx;
    DEALLOCATE PREPARE createclientididx;

END //

DELIMITER ;