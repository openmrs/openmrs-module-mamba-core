DELIMITER //

DROP PROCEDURE IF EXISTS sp_mamba_generate_report;

CREATE PROCEDURE sp_mamba_generate_report(
    IN report_id VARCHAR(255),
    IN arguments JSON
)
BEGIN

    DECLARE i INT DEFAULT 0;
    DECLARE num_objects INT;
    DECLARE current_json JSON;
    DECLARE column_name VARCHAR(255);
    DECLARE column_value VARCHAR(255);
    DECLARE dynamic_sql VARCHAR(2000);

    -- Create a temporary table to store the mapping of column_name to parameter
    DROP TEMPORARY TABLE IF EXISTS mamba_dim_temp_mapping;

    CREATE TEMPORARY TABLE mamba_dim_temp_mapping
    (
        column_name     VARCHAR(255),
        parameter_value VARCHAR(255)
    );

    -- SET num_objects = JSON_LENGTH(JSON_EXTRACT(json_arguments, '$.arguments'));
    SET num_objects = JSON_LENGTH(arguments);

    WHILE i < num_objects
        DO
            -- SET current_json = JSON_EXTRACT(json_arguments, CONCAT('$.arguments[', i, ']'));
            SET current_json = JSON_EXTRACT(arguments, CONCAT('$[', i, ']'));

            SET column_name = JSON_UNQUOTE(JSON_EXTRACT(current_json, '$.column'));
            SET column_value = JSON_UNQUOTE(JSON_EXTRACT(current_json, '$.value'));

            INSERT INTO mamba_dim_temp_mapping (column_name, parameter_value)
            VALUES (column_name, column_value);

            SET i = i + 1;
        END WHILE;

    -- TODO: Read parameters from the table definition provided by the json config - it has the position iD for the variables,
    -- you can use that to put the params in the right positions when calling the SP

    -- call the appropriate sp for the report
    SET @report_identifier = report_id;

    SELECT DISTINCT report_procedure_name
    INTO @procedure_name
    FROM mamba_dim_report_definition
    WHERE report_id = @report_identifier
    LIMIT 1;

    SET @generate_sql = CONCAT('CALL ', @procedure_name, '(');
    SELECT GROUP_CONCAT(DISTINCT CONCAT('\'', parameter_value, '\''))
    INTO @dynamic_sql
    FROM mamba_dim_temp_mapping
    LIMIT 1;

    SET @call_report_sql = CONCAT(@generate_sql, @dynamic_sql, ');');

    PREPARE prepared_statement FROM @call_report_sql;
    EXECUTE prepared_statement;
    DEALLOCATE PREPARE prepared_statement;

    DROP TEMPORARY TABLE IF EXISTS mamba_dim_temp_mapping;

END //

DELIMITER ;



