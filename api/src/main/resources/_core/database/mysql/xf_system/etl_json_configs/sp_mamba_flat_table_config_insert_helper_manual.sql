-- manually extracts user given flat table config file json into the mamba_flat_table_config table
-- this data together with automatically extracted flat table data is inserted into the mamba_flat_table_config table
-- later it is processed by the 'fn_mamba_generate_report_array_from_automated_json_table' function
-- into the @report_data variable inside the compile-mysql.sh script

DROP PROCEDURE IF EXISTS sp_mamba_flat_table_config_insert_helper_manual;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_table_config_insert_helper_manual(
    IN report_data JSON
)
BEGIN

    DECLARE report_count INT DEFAULT 0;
    DECLARE report_array_len INT;
    DECLARE report_enc_type_id INT DEFAULT NULL;
    DECLARE report_enc_type_uuid VARCHAR(50);
    DECLARE report_enc_name VARCHAR(500);

    SET session group_concat_max_len = 200000;

    SELECT JSON_EXTRACT(report_data, '$.flat_report_metadata') INTO @report_array;
    SELECT JSON_LENGTH(@report_array) INTO report_array_len;

    WHILE report_count < report_array_len
        DO

            SELECT JSON_EXTRACT(@report_array, CONCAT('$[', report_count, ']')) INTO @report_data_item;
            SELECT JSON_EXTRACT(@report_data_item, '$.report_name') INTO report_enc_name;
            SELECT JSON_EXTRACT(@report_data_item, '$.encounter_type_uuid') INTO report_enc_type_uuid;

            SET report_enc_type_uuid = JSON_UNQUOTE(report_enc_type_uuid);

            SET report_enc_type_id = (SELECT DISTINCT et.encounter_type_id
                                      FROM mamba_dim_encounter_type et
                                      WHERE et.uuid = report_enc_type_uuid
                                      LIMIT 1);

            IF report_enc_type_id IS NOT NULL THEN
                INSERT INTO mamba_flat_table_config
                (report_name,
                 encounter_type_id,
                 table_json_data,
                 encounter_type_uuid)
                VALUES (JSON_UNQUOTE(report_enc_name),
                        report_enc_type_id,
                        @report_data_item,
                        report_enc_type_uuid);
            END IF;

            SET report_count = report_count + 1;

        END WHILE;

END //

DELIMITER ;