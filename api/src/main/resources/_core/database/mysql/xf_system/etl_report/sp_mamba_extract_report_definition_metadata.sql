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

        SELECT JSON_EXTRACT(report_definition_json, '$.report_definitions') INTO @report_array;
        SELECT JSON_LENGTH(@report_array) INTO @report_array_len;

        SET @report_count = 0;
        WHILE @report_count < @report_array_len
            DO

                SELECT JSON_EXTRACT(@report_array, CONCAT('$[', @report_count, ']')) INTO @report;
                SELECT JSON_UNQUOTE(JSON_EXTRACT(@report, '$.report_name')) INTO @report_name;
                SELECT JSON_UNQUOTE(JSON_EXTRACT(@report, '$.report_id')) INTO @report_id;

                SELECT CONCAT('sp_mamba_report_', @report_id, '_query') INTO @report_procedure_name;
                SELECT CONCAT('sp_mamba_report_', @report_id, '_columns_query') INTO @report_columns_procedure_name;
                SELECT CONCAT('sp_mamba_report_', @report_id, '_size_query') INTO @report_size_procedure_name;
                SELECT CONCAT('mamba_report_', @report_id) INTO @table_name;

                SELECT JSON_UNQUOTE(JSON_EXTRACT(@report, CONCAT('$.report_sql.sql_query'))) INTO @sql_query;
                SELECT JSON_EXTRACT(@report, CONCAT('$.report_sql.query_params')) INTO @query_params_array;
                SELECT JSON_EXTRACT(@report, CONCAT('$.report_sql.paginate')) INTO @paginate_flag;

                INSERT INTO mamba_dim_report_definition(report_id,
                                                        report_procedure_name,
                                                        report_columns_procedure_name,
                                                        report_size_procedure_name,
                                                        sql_query,
                                                        table_name,
                                                        report_name)
                VALUES (@report_id,
                        @report_procedure_name,
                        @report_columns_procedure_name,
                        @report_size_procedure_name,
                        @sql_query,
                        @table_name,
                        @report_name);

                -- Iterate over the "params" array for each report
                SELECT JSON_LENGTH(@query_params_array) INTO @total_params;

                SET @parameters := NULL;
                SET @param_count = 0;
                WHILE @param_count < @total_params
                    DO
                        SELECT JSON_EXTRACT(@query_params_array, CONCAT('$[', @param_count, ']')) INTO @param;
                        SELECT JSON_UNQUOTE(JSON_EXTRACT(@param, '$.name')) INTO @param_name;
                        SELECT JSON_UNQUOTE(JSON_EXTRACT(@param, '$.type')) INTO @param_type;
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

                -- Handle pagination parameters if paginate flag is true
                IF @paginate_flag = TRUE OR @paginate_flag = 'true' THEN
                    -- Add page_number parameter
                    SET @page_number_position = @total_params + 1;
                    INSERT INTO mamba_dim_report_definition_parameters(report_id,
                                                                      parameter_name,
                                                                      parameter_type,
                                                                      parameter_position)
                    VALUES (@report_id,
                            'page_number',
                            'INT',
                            @page_number_position);
                            
                    -- Add page_size parameter
                    SET @page_size_position = @total_params + 2;
                    INSERT INTO mamba_dim_report_definition_parameters(report_id,
                                                                      parameter_name,
                                                                      parameter_type,
                                                                      parameter_position)
                    VALUES (@report_id,
                            'page_size',
                            'INT',
                            @page_size_position);
                END IF;

                SET @report_count = @report_count + 1;
            END WHILE;

    END IF;

END //

DELIMITER ;