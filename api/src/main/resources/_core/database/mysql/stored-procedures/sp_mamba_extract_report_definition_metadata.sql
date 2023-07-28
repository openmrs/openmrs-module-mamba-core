DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_extract_report_definition_metadata;

CREATE PROCEDURE sp_mamba_extract_report_definition_metadata(
    IN report_definition_json JSON,
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    IF report_definition_json IS NULL OR JSON_LENGTH(report_definition_json) = 0 THEN
        SIGNAL SQLSTATE '02000'
            SET MESSAGE_TEXT = 'Warn: report_definition_json is empty or null.';
    ELSE

        SET session group_concat_max_len = 20000;

        SELECT JSON_EXTRACT(report_definition_json, '$.report_definitions') INTO @report_array;
        SELECT JSON_LENGTH(@report_array) INTO @report_array_len;

        SET @report_count = 0;
        WHILE @report_count < @report_array_len
            DO

                SELECT JSON_EXTRACT(@report_array, CONCAT('$[', @report_count, ']')) INTO @report;
                SELECT JSON_EXTRACT(@report, '$.report_name') INTO @report_name;
                SELECT JSON_EXTRACT(@report, '$.report_id') INTO @report_id;
                SELECT JSON_EXTRACT(@report, '$.report_procedure_name') INTO @report_procedure_name;


                SELECT JSON_KEYS(@column_array) INTO @column_keys_array;
                SELECT JSON_LENGTH(@column_keys_array) INTO @column_keys_array_len;
                SET @col_count = 0;
                WHILE @col_count < @column_keys_array_len
                    DO
                        SELECT JSON_EXTRACT(@column_keys_array, CONCAT('$[', @col_count, ']')) INTO @field_name;
                        SELECT JSON_EXTRACT(@column_array, CONCAT('$.', @field_name)) INTO @concept_uuid;

                        SET @tbl_name = '';
                        INSERT INTO mamba_dim_report_definition(report_id, report_procedure_name, report_name)
                        VALUES (JSON_UNQUOTE(@report_name),
                                JSON_UNQUOTE(@report_id),
                                JSON_UNQUOTE(@report_procedure_name));

                        SET @col_count = @col_count + 1;
                    END WHILE;

                SET @report_count = @report_count + 1;
            END WHILE;

    END IF;

END //

DELIMITER ;