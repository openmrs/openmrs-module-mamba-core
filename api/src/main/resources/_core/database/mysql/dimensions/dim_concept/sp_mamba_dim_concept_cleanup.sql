DROP PROCEDURE IF EXISTS sp_mamba_dim_concept_cleanup;

DELIMITER //

CREATE PROCEDURE sp_mamba_dim_concept_cleanup()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_id INT;
    DECLARE current_auto_table_column_name VARCHAR(60);
    DECLARE previous_auto_table_column_name VARCHAR(60) DEFAULT '';
    DECLARE counter INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT concept_id, auto_table_column_name
        FROM mamba_dim_concept
        ORDER BY auto_table_column_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_dim_concept_temp
    (
        concept_id             INT,
        auto_table_column_name VARCHAR(60)
    );

    TRUNCATE TABLE mamba_dim_concept_temp;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO current_id, current_auto_table_column_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF current_auto_table_column_name IS NULL THEN
            SET current_auto_table_column_name = '';
        END IF;

        IF current_auto_table_column_name = previous_auto_table_column_name THEN

            SET counter = counter + 1;
            SET current_auto_table_column_name = CONCAT(
                    IF(CHAR_LENGTH(previous_auto_table_column_name) <= 57,
                       previous_auto_table_column_name,
                       LEFT(previous_auto_table_column_name, CHAR_LENGTH(previous_auto_table_column_name) - 3)
                    ),
                    '_',
                    counter);
        ELSE
            SET counter = 0;
            SET previous_auto_table_column_name = current_auto_table_column_name;
        END IF;

        INSERT INTO mamba_dim_concept_temp (concept_id, auto_table_column_name)
        VALUES (current_id, current_auto_table_column_name);

    END LOOP;

    CLOSE cur;

    UPDATE mamba_dim_concept c
        JOIN mamba_dim_concept_temp t
        ON c.concept_id = t.concept_id
    SET c.auto_table_column_name = t.auto_table_column_name
    WHERE c.concept_id > 0;

    DROP TEMPORARY TABLE IF EXISTS mamba_dim_concept_temp;

END //

DELIMITER ;