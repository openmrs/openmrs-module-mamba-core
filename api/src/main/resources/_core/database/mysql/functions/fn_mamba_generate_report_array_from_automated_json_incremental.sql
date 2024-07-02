DROP FUNCTION IF EXISTS fn_mamba_generate_report_array_from_automated_json_incremental;

DELIMITER //

CREATE FUNCTION fn_mamba_generate_report_array_from_automated_json_incremental() RETURNS MEDIUMTEXT
    DETERMINISTIC
BEGIN
    DECLARE report_array MEDIUMTEXT;
    SET session group_concat_max_len = 200000;

    SELECT CONCAT('{"flat_report_metadata":[', GROUP_CONCAT(
            CONCAT(
                    '{'
                        ',"report_name":', JSON_EXTRACT(json_data, '$.report_name'),
                        ',"flat_table_name":', JSON_EXTRACT(json_data, '$.flat_table_name'),
                        ',"encounter_type_uuid":', JSON_EXTRACT(json_data, '$.encounter_type_uuid'),
                        ',"table_columns": ', JSON_EXTRACT(json_data, '$.table_columns'),
                    '}'
            ) SEPARATOR ','), ']}')
    INTO report_array
    FROM mamba_dim_json;
    -- WHERE uuid NOT IN (SELECT  DISTINCT encounter_type_uuid from mamba_dim_concept_metadata);

    RETURN report_array;

END //

DELIMITER ;