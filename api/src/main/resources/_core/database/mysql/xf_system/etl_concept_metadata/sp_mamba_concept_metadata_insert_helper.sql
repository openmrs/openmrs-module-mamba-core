DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_insert_helper;

DELIMITER //

CREATE PROCEDURE sp_mamba_concept_metadata_insert_helper(
    IN is_incremental TINYINT(1),
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    DECLARE is_incremental_record TINYINT(1) DEFAULT 0;
    DECLARE report_json JSON;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        -- selects rows where incremental_record is 1. If is_incremental is not 1, it selects all rows.
        SELECT table_json_data
        FROM mamba_flat_table_config
        WHERE (IF(is_incremental = 1, incremental_record = 1, 1));

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET session group_concat_max_len = 20000;

    SELECT DISTINCT(table_partition_number)
    INTO @table_partition_number
    FROM _mamba_etl_user_settings;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO report_json;

        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT JSON_EXTRACT(report_json, '$.report_name') INTO @report_name;
        SELECT JSON_EXTRACT(report_json, '$.flat_table_name') INTO @flat_table_name;
        SELECT JSON_EXTRACT(report_json, '$.encounter_type_uuid') INTO @encounter_type;
        SELECT JSON_EXTRACT(report_json, '$.table_columns') INTO @column_array;

        SELECT JSON_KEYS(@column_array) INTO @column_keys_array;
        SELECT JSON_LENGTH(@column_keys_array) INTO @column_keys_array_len;

        -- if is_incremental = 1, delete records (if they exist) from mamba_concept_metadata table with encounter_type_uuid = @encounter_type
        IF is_incremental = 1 THEN

            SET is_incremental_record = 1;
            SET @delete_query = CONCAT('DELETE FROM mamba_concept_metadata WHERE encounter_type_uuid = ''',
                                       JSON_UNQUOTE(@encounter_type), '''');

            PREPARE stmt FROM @delete_query;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;

        IF @column_keys_array_len = 0 THEN

            INSERT INTO mamba_concept_metadata
            (report_name,
             flat_table_name,
             encounter_type_uuid,
             column_label,
             concept_uuid,
             incremental_record)
            VALUES (JSON_UNQUOTE(@report_name),
                    JSON_UNQUOTE(@flat_table_name),
                    JSON_UNQUOTE(@encounter_type),
                    'AUTO-GENERATE',
                    'AUTO-GENERATE',
                    is_incremental_record);
        ELSE

            SET @col_count = 0;
            SET @table_name = JSON_UNQUOTE(@flat_table_name);


            WHILE @col_count < @column_keys_array_len
                DO
                    SELECT JSON_EXTRACT(@column_keys_array, CONCAT('$[', @col_count, ']')) INTO @field_name;
                    SELECT JSON_EXTRACT(@column_array, CONCAT('$.', @field_name)) INTO @concept_uuid;

                    IF @col_count < @table_partition_number THEN
                        SET @table_name = @table_name;
                    ELSEIF @col_count = @table_partition_number THEN
                        SET @table_name = CONCAT(LEFT(JSON_UNQUOTE(@flat_table_name), 57), '_', CEIL(@col_count/@table_partition_number));
                    ELSE
                        SET @table_name = CONCAT(LEFT(JSON_UNQUOTE(@flat_table_name), 57), '_', CEIL(@col_count/@table_partition_number)-1);
                    END IF;

                    INSERT INTO mamba_concept_metadata
                    (report_name,
                     flat_table_name,
                     encounter_type_uuid,
                     column_label,
                     concept_uuid,
                     incremental_record)
                    VALUES (JSON_UNQUOTE(@report_name),
                            JSON_UNQUOTE(@table_name),
                            JSON_UNQUOTE(@encounter_type),
                            JSON_UNQUOTE(@field_name),
                            JSON_UNQUOTE(@concept_uuid),
                            is_incremental_record);
                    SET @col_count = @col_count + 1;
                END WHILE;
        END IF;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;