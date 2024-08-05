DROP PROCEDURE IF EXISTS sp_mamba_concept_metadata_insert_helper;

DELIMITER //

CREATE PROCEDURE sp_mamba_concept_metadata_insert_helper(
    IN is_incremental TINYINT(1),
    IN report_data JSON,
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    DECLARE is_incremental_record TINYINT(1) DEFAULT 0;

    SET session group_concat_max_len = 20000;

    SELECT DISTINCT(table_partition_number)
    INTO @table_partition_number
    FROM _mamba_etl_user_settings;

    SELECT JSON_EXTRACT(report_data, '$.flat_report_metadata') INTO @report_array;
    SELECT JSON_LENGTH(@report_array) INTO @report_array_len;

    SET @report_count = 0;
    WHILE @report_count < @report_array_len
        DO

            SELECT JSON_EXTRACT(@report_array, CONCAT('$[', @report_count, ']')) INTO @report;
            SELECT JSON_EXTRACT(@report, '$.report_name') INTO @report_name;
            SELECT JSON_EXTRACT(@report, '$.flat_table_name') INTO @flat_table_name;
            SELECT JSON_EXTRACT(@report, '$.encounter_type_uuid') INTO @encounter_type;
            SELECT JSON_EXTRACT(@report, '$.table_columns') INTO @column_array;

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
                SET @current_table_count = 1;

                WHILE @col_count < @column_keys_array_len
                    DO
                        SELECT JSON_EXTRACT(@column_keys_array, CONCAT('$[', @col_count, ']')) INTO @field_name;
                        SELECT JSON_EXTRACT(@column_array, CONCAT('$.', @field_name)) INTO @concept_uuid;

                        IF @col_count > @table_partition_number THEN

                            SET @table_name = CONCAT(JSON_UNQUOTE(@flat_table_name), '_', @current_table_count);
                            SET @current_table_count = @current_table_count;

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

                        ELSE
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
                                    JSON_UNQUOTE(@field_name),
                                    JSON_UNQUOTE(@concept_uuid),
                                    is_incremental_record);
                        END IF;


                        SET @col_count = @col_count + 1;

                    END WHILE;
            END IF;

            SET @report_count = @report_count + 1;
        END WHILE;

END //

DELIMITER ;