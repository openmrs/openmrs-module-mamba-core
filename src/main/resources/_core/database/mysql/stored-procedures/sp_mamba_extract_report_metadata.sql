DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_extract_report_metadata;

CREATE PROCEDURE sp_mamba_extract_report_metadata(
    IN report_data MEDIUMTEXT CHARACTER SET UTF8MB4,
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;

SELECT  JSON_EXTRACT_ARRAY(report_data, 'flat_report_metadata') INTO @report_array;
SELECT JSON_ARRAY_LENGTH(@report_array) INTO @report_array_len;

SET @report_count = 1;
    WHILE @report_count <= @report_array_len
        DO
            SELECT  JSON_OBJECT_AT_INDEX(@report_array, @report_count) INTO @report;
            SET @report =  CONCAT(@report,'}');
            SELECT  JSON_EXTRACT_1(@report, 'report_name') INTO @report_name;
            SELECT  JSON_EXTRACT_1(@report, 'flat_table_name') INTO @flat_table_name;
            SELECT  JSON_EXTRACT_1(@report, 'encounter_type_uuid') INTO @encounter_type;
            SELECT  JSON_EXTRACT_1(@report, 'concepts_locale') INTO @concepts_locale;
            SELECT  JSON_EXTRACT_OBJECT(@report, 'table_columns') INTO @column_array;
            SELECT JSON_KEYS_ARRAY(@column_array) INTO @column_keys_array;
            SELECT ARRAY_LENGTH(@column_keys_array) INTO @column_keys_array_len;

            SET @col_count = 1;
            SET @column_array = CONCAT('{',@column_array,'}');
            WHILE @col_count <= @column_keys_array_len
                DO
                    SELECT  GET_ARRAY_ITEM_BY_INDEX(@column_keys_array, @col_count) INTO @field_name;
                    SELECT JSON_VALUE_BY_KEY(@column_array,  @field_name) INTO @concept_uuid;

                    SET @tbl_name = '';
                    INSERT INTO mamba_dim_concept_metadata(report_name,
                                                           flat_table_name,
                                                           encounter_type_uuid,
                                                           column_label,
                                                           concept_uuid,
                                                           concepts_locale)
                    VALUES (REMOVE_QUOTES(@report_name),
                            REMOVE_QUOTES(@flat_table_name),
                            REMOVE_QUOTES(@encounter_type),
                            REMOVE_QUOTES(@field_name),
                            REMOVE_QUOTES(@concept_uuid),
                            REMOVE_QUOTES(@concepts_locale));

                    SET @col_count = @col_count + 1;
            END WHILE;

            SET @report_count = @report_count + 1;
    END WHILE;

END //

DELIMITER ;