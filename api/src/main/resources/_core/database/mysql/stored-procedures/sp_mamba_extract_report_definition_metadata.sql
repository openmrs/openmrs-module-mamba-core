DROP PROCEDURE IF EXISTS sp_mamba_extract_report_definition_metadata;

DELIMITER //

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

        SELECT fn_mamba_json_extract_array(report_definition_json, 'report_definitions') INTO @report_array;
        SELECT fn_mamba_json_array_length(@report_array) INTO @report_array_len;

        SET @report_count = 1;
        WHILE @report_count < @report_array_len
            DO

                SELECT fn_mamba_json_object_at_index(@report_array,@report_count) INTO @report;
                SET @report =  CONCAT(@report,'] } }');
                SELECT fn_mamba_json_extract(@report, 'report_name') INTO @report_name;
                SELECT fn_mamba_json_extract(@report, 'report_id') INTO @report_id;
                SELECT fn_mamba_remove_quotes(CONCAT('sp_mamba_', @report_id, '_query')) INTO @report_procedure_name;
                SELECT fn_mamba_remove_quotes(CONCAT('sp_mamba_', @report_id, '_columns_query'))INTO @report_columns_procedure_name;
                SELECT fn_mamba_remove_quotes(CONCAT('mamba_dim_', @report_id)) INTO @table_name;
                SELECT fn_mamba_json_extract(@report, 'sql_query') INTO @sql_query;
                SELECT fn_mamba_json_extract(@report,'report_sql.query_params') INTO @query_params_array;

                INSERT INTO mamba_dim_report_definition(report_id,
                                                        report_procedure_name,
                                                        report_columns_procedure_name,
                                                        sql_query,
                                                        table_name,
                                                        report_name)
                VALUES (@report_id,
                        @report_procedure_name,
                        @report_columns_procedure_name,
                        @sql_query,
                        @table_name,
                        @report_name);

                -- Iterate over the "params" array for each report
                SELECT fn_mamba_json_length(@query_params_array) INTO @total_params;

                SET @parameters := NULL;
                SET @param_count = 0;
                WHILE @param_count < @total_params
                    DO
                        SELECT fn_mamba_json_object_at_index(@query_params_array,@param_count) INTO @param;
                        SET @report =  CONCAT('[',@param,']');
                        SELECT fn_mamba_json_object_at_index(@param, 'name') INTO @param_name;
                        SELECT fn_mamba_json_object_at_index(@param, 'type') INTO @param_type;
                        SET @param_position = @param_count + 1;

                        INSERT INTO mamba_dim_report_definition_parameters(report_id,
                                                                           parameter_name,
                                                                           parameter_type,
                                                                           parameter_position)
                        VALUES (@report_id,
                                @param_name,
                                @param_type,
                                @param_position);

                        SET @param_count = @param_position;
                    END WHILE;
                SET @report_count = @report_count + 1;
            END WHILE;

    END IF;

END //

DELIMITER ;