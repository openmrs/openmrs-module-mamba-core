DROP FUNCTION IF EXISTS fn_mamba_generate_json_from_mamba_flat_table_config;

DELIMITER //

CREATE FUNCTION fn_mamba_generate_json_from_mamba_flat_table_config(
    is_incremental TINYINT(1)
) RETURNS JSON
    DETERMINISTIC
BEGIN
    DECLARE report_array JSON;
    SET session group_concat_max_len = 200000;

    SELECT CONCAT('{"flat_report_metadata":[', GROUP_CONCAT(
            CONCAT(
                    '{',
                    '"report_name":', JSON_EXTRACT(table_json_data, '$.report_name'),
                    ',"flat_table_name":', JSON_EXTRACT(table_json_data, '$.flat_table_name'),
                    ',"encounter_type_uuid":', JSON_EXTRACT(table_json_data, '$.encounter_type_uuid'),
                    ',"table_columns": ', JSON_EXTRACT(table_json_data, '$.table_columns'),
                    '}'
            ) SEPARATOR ','), ']}')
    INTO report_array
    FROM mamba_flat_table_config
    WHERE (IF(is_incremental = 1, incremental_record = 1, 1));

    RETURN report_array;

END //

DELIMITER ;