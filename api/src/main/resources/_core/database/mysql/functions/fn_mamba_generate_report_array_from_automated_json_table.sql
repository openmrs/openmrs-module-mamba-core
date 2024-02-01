DROP FUNCTION IF EXISTS fn_mamba_generate_report_array_from_automated_json_table;

DELIMITER //

CREATE FUNCTION fn_mamba_generate_report_array_from_automated_json_table() RETURNS JSON
    DETERMINISTIC
BEGIN
    DECLARE report_array JSON;

    SELECT JSON_OBJECT('flat_report_metadata', JSON_ARRAYAGG(JSON_EXTRACT(Json_data, '$')))
    INTO report_array
    FROM mamba_dim_json;

    RETURN report_array;
END //

DELIMITER ;