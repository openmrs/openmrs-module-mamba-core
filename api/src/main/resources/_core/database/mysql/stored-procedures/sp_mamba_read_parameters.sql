CREATE PROCEDURE my_procedure(IN json_arguments JSON)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE num_objects INT;
    DECLARE current_json JSON;
    DECLARE column_name VARCHAR(255);
    DECLARE column_value VARCHAR(255);

    -- Get the number of JSON objects in the 'arguments' array
    SET num_objects = JSON_LENGTH(JSON_EXTRACT(json_arguments, '$.arguments'));

    WHILE i < num_objects
        DO
            -- Extract the current JSON object from the 'arguments' array
            SET current_json = JSON_EXTRACT(json_arguments, CONCAT('$.arguments[', i, ']'));

            -- Extract 'column' and 'value' from the current JSON object
            SET column_name = JSON_UNQUOTE(JSON_EXTRACT(current_json, '$.column'));
            SET column_value = JSON_UNQUOTE(JSON_EXTRACT(current_json, '$.value'));

            -- Perform operations using 'column_name' and 'column_value'
            -- For example:
            IF column_name = 'ptracker_id' THEN
                SELECT * FROM your_table WHERE ptracker_id_column = column_value;
            ELSEIF column_name = 'person_uuid' THEN
                SELECT * FROM another_table WHERE person_uuid_column = column_value;
            END IF;

            -- Additional operations...

            SET i = i + 1;
        END WHILE;
END;
