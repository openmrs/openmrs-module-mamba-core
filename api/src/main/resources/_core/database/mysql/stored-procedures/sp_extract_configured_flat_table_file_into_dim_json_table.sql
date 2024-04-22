-- manually extracts user given flat table config files into the mamba_dim_json table
-- this data together with automatically extracted flat table data is inserted into the mamba_dim_json table
-- later it is processed by the 'fn_mamba_generate_report_array_from_automated_json_table' function
-- into the @report_data variable inside the compile-mysql.sh script

DROP PROCEDURE IF EXISTS sp_extract_configured_flat_table_file_into_dim_json_table;

DELIMITER //

CREATE PROCEDURE sp_extract_configured_flat_table_file_into_dim_json_table(
    IN report_data MEDIUMTEXT CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;

    SELECT fn_mamba_json_extract_array(report_data, 'flat_report_metadata') INTO @report_array;
    SELECT fn_mamba_json_array_length(@report_array) INTO @report_array_len;

    SET @report_count = 1;
    WHILE @report_count <= @report_array_len
        DO

            SELECT fn_mamba_json_object_at_index(@report_array, @report_count) INTO @report_data_item;
            SET @report_data_item =  CONCAT(@report_data_item,'}');
            SELECT fn_mamba_json_extract(@report_data_item, 'report_name') INTO @report_name;
            SELECT fn_mamba_json_extract(@report_data_item, 'encounter_type_uuid') INTO @encounter_type_uuid;

            SET @et_uuid = fn_mamba_remove_quotes(@encounter_type_uuid);

            SELECT DISTINCT encounter_type_id
            INTO @encounter_type_id
            FROM mamba_dim_encounter_type
            WHERE uuid = @et_uuid
            LIMIT 1;

            INSERT INTO mamba_dim_json
            (report_name,
             encounter_type_id,
             Json_data,
             uuid)
            VALUES (fn_mamba_remove_quotes(@report_name),
                    @encounter_type_id,
                    @report_data_item,
                    @et_uuid);

            SET @report_count = @report_count + 1;
        END WHILE;

END //

DELIMITER ;