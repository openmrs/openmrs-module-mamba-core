DROP PROCEDURE IF EXISTS sp_mamba_extract_report_metadata;

DELIMITER //

CREATE PROCEDURE sp_mamba_extract_report_metadata(
    IN report_data MEDIUMTEXT CHARACTER SET UTF8MB4,
    IN metadata_table VARCHAR(255) CHARSET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;

    SELECT DISTINCT(table_partition_number)
    INTO @table_partition_number
    FROM mamba_etl_user_settings;

    SELECT fn_mamba_json_extract_array(report_data, 'flat_report_metadata') INTO @report_array;
    SELECT fn_mamba_json_array_length(@report_array) INTO @report_array_len;

    SET @report_count = 1;
        WHILE @report_count <= @report_array_len
            DO
                SELECT fn_mamba_json_object_at_index(@report_array, @report_count) INTO @report;
                SET @report =  CONCAT(@report,'}');
                SELECT fn_mamba_json_extract(@report, 'report_name') INTO @report_name;
                SELECT fn_mamba_json_extract(@report, 'flat_table_name') INTO @flat_table_name;
                SELECT fn_mamba_json_extract(@report, 'encounter_type_uuid') INTO @encounter_type;
                SELECT fn_mamba_json_extract_object(@report, 'table_columns') INTO @column_array;

                SELECT fn_mamba_json_keys_array(@column_array) INTO @column_keys_array;
                SELECT fn_mamba_array_length(@column_keys_array) INTO @column_keys_array_len;

                SET @column_array = CONCAT('{',@column_array,'}');
                IF @column_keys_array_len = 0 THEN

                     INSERT INTO mamba_dim_concept_metadata
                        (
                            report_name,
                            flat_table_name,
                            encounter_type_uuid,
                            column_label,
                            concept_uuid
                        )
                     VALUES (fn_mamba_remove_quotes(@report_name),
                            fn_mamba_remove_quotes(@flat_table_name),
                            fn_mamba_remove_quotes(@encounter_type),
                            'AUTO-GENERATE',
                            'AUTO-GENERATE');
                ELSE

                    SET @col_count = 1;
                    SET @table_name = fn_mamba_remove_quotes(@flat_table_name);
                    SET @current_table_count = 1;

                    WHILE @col_count <= @column_keys_array_len
                        DO
                            SELECT fn_mamba_get_array_item_by_index(@column_keys_array, @col_count) INTO @field_name;
                            SELECT fn_mamba_json_value_by_key(@column_array,  @field_name) INTO @concept_uuid;

                            IF @col_count > @table_partition_number THEN
                                SET @table_name = CONCAT(fn_mamba_remove_quotes(@flat_table_name), '_', @current_table_count);
                                SET @current_table_count = @current_table_count;
                                INSERT INTO mamba_dim_concept_metadata
                                (
                                    report_name,
                                    flat_table_name,
                                    encounter_type_uuid,
                                    column_label,
                                    concept_uuid
                                )
                                VALUES (fn_mamba_remove_quotes(@report_name),
                                        fn_mamba_remove_quotes(@table_name),
                                        fn_mamba_remove_quotes(@encounter_type),
                                        fn_mamba_remove_quotes(@field_name),
                                        fn_mamba_remove_quotes(@concept_uuid));

                            ELSE
                                INSERT INTO mamba_dim_concept_metadata
                                (
                                    report_name,
                                    flat_table_name,
                                    encounter_type_uuid,
                                    column_label,
                                    concept_uuid
                                )
                                VALUES (fn_mamba_remove_quotes(@report_name),
                                        fn_mamba_remove_quotes(@flat_table_name),
                                        fn_mamba_remove_quotes(@encounter_type),
                                        fn_mamba_remove_quotes(@field_name),
                                        fn_mamba_remove_quotes(@concept_uuid));
                            END IF;


                            SET @col_count = @col_count + 1;

                        END WHILE;
                END IF;

                    SET @report_count = @report_count + 1;
            END WHILE;

END //

DELIMITER ;