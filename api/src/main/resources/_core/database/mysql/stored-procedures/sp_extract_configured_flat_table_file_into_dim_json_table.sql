-- manually extracts user given flat table config files into the mamba_dim_json table
-- this data together with automatically extracted flat table data is inserted into the mamba_dim_json table
-- Llater it is processed by the 'fn_mamba_generate_report_array_from_automated_json_table' function
-- into the @report_data variable inside the compile-mysql.sh script

DROP PROCEDURE IF EXISTS sp_extract_configured_flat_table_file_into_dim_json_table;

DELIMITER //

CREATE PROCEDURE sp_extract_configured_flat_table_file_into_dim_json_table(
    IN report_data_item MEDIUMTEXT CHARACTER SET UTF8MB4,
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;

    SELECT JSON_EXTRACT(report_data_item, '$.report_name') INTO @report_name;
    SELECT JSON_EXTRACT(report_data_item, '$.flat_table_name') INTO @flat_table_name;
    SELECT JSON_EXTRACT(report_data_item, '$.encounter_type_uuid') INTO @encounter_type;
    SELECT JSON_EXTRACT(report_data_item, '$.concepts_locale') INTO @concepts_locale;
    SELECT JSON_EXTRACT(report_data_item, '$.table_columns') INTO @column_array;

    SELECT DISTINCT encounter_type_id
    INTO @encounter_type_id
    FROM mamba_dim_encounter_type
    WHERE uuid = @report_identifier
    LIMIT 1;

    INSERT INTO mamba_dim_json
    (report_name,
     @encounter_type_id,
     Json_data,
     uuid)
    VALUES (JSON_UNQUOTE(@report_name),
            JSON_UNQUOTE(@encounter_type),
            report_data_item,
            JSON_UNQUOTE(@encounter_type));

END //

DELIMITER ;