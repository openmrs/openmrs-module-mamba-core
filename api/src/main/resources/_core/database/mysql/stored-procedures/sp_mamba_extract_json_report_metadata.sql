DROP PROCEDURE IF EXISTS sp_mamba_extract_json_report_metadata;

DELIMITER //

CREATE PROCEDURE sp_mamba_extract_json_report_metadata(
)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM mamba_dim_concept_metadata) THEN
        SET session group_concat_max_len = 20000;

        -- SELECT JSON_EXTRACT(report_data, '$.flat_report_metadata') INTO @report_array;
        SELECT JSON_ARRAYAGG(JSON_EXTRACT(Json_data, '$')) INTO @report_array FROM mamba_dim_json;
        SELECT JSON_LENGTH(@report_array) INTO @report_array_len;

        SET @report_count = 0;
            WHILE @report_count < @report_array_len
                DO

                    SELECT JSON_EXTRACT(@report_array, CONCAT('$[', @report_count, ']')) INTO @report;
                    SELECT JSON_EXTRACT(@report, '$.report_name') INTO @report_name;
                    SELECT JSON_EXTRACT(@report, '$.flat_table_name') INTO @flat_table_name;
                    SELECT JSON_EXTRACT(@report, '$.encounter_type_uuid') INTO @encounter_type;
                    SELECT JSON_EXTRACT(@report, '$.concepts_locale') INTO @concepts_locale;
                    SELECT JSON_EXTRACT(@report, '$.table_columns') INTO @column_array;

                    SELECT JSON_KEYS(@column_array) INTO @column_keys_array;
                    SELECT JSON_LENGTH(@column_keys_array) INTO @column_keys_array_len;
                    SET @col_count = 0;
                                WHILE @col_count < @column_keys_array_len
                                    DO
                                        SELECT JSON_EXTRACT(@column_keys_array, CONCAT('$[', @col_count, ']')) INTO @field_name;
                                        SELECT JSON_EXTRACT(@column_array, CONCAT('$.', @field_name)) INTO @concept_uuid;

                                        SET @tbl_name = '';
                                        INSERT INTO mamba_dim_concept_metadata
                                        (
                                            report_name,
                                            flat_table_name,
                                            encounter_type_uuid,
                                            column_label,
                                            concept_uuid,
                                            concepts_locale
                                        )
                                        VALUES (JSON_UNQUOTE(@report_name),
                                                JSON_UNQUOTE(@flat_table_name),
                                                JSON_UNQUOTE(@encounter_type),
                                                JSON_UNQUOTE(@field_name),
                                                JSON_UNQUOTE(@concept_uuid),
                                                JSON_UNQUOTE(@concepts_locale));

                                        SET @col_count = @col_count + 1;
                                END WHILE;

                                SET @report_count = @report_count + 1;
            END WHILE;
    END IF;
END //

DELIMITER ;