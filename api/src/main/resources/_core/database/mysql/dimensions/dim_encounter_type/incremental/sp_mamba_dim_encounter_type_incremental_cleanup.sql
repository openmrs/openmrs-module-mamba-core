DROP PROCEDURE IF EXISTS sp_mamba_dim_encounter_type_incremental_cleanup;

DELIMITER //

CREATE PROCEDURE sp_mamba_dim_encounter_type_incremental_cleanup()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_id INT;
    DECLARE current_auto_flat_table_name VARCHAR(60);
    DECLARE previous_auto_flat_table_name VARCHAR(60) DEFAULT '';
    DECLARE counter INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT encounter_type_id, auto_flat_table_name
        FROM mamba_dim_encounter_type
        WHERE incremental_record = 1
        ORDER BY auto_flat_table_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS mamba_dim_encounter_type_temp
    (
        encounter_type_id    INT,
        auto_flat_table_name VARCHAR(60)
    );

    TRUNCATE TABLE mamba_dim_encounter_type_temp;

    OPEN cur;

    read_loop:
    LOOP
        FETCH cur INTO current_id, current_auto_flat_table_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        IF current_auto_flat_table_name IS NULL THEN
            SET current_auto_flat_table_name = '';
        END IF;

        IF current_auto_flat_table_name = previous_auto_flat_table_name THEN

            SET counter = counter + 1;
            SET current_auto_flat_table_name = CONCAT(
                    IF(LENGTH(previous_auto_flat_table_name) <= 57,
                       previous_auto_flat_table_name,
                       LEFT(previous_auto_flat_table_name, LENGTH(previous_auto_flat_table_name) - 3)
                    ),
                    '_',
                    counter);
        ELSE
            SET counter = 0;
            SET previous_auto_flat_table_name = current_auto_flat_table_name;
        END IF;

        INSERT INTO mamba_dim_encounter_type_temp (encounter_type_id, auto_flat_table_name)
        VALUES (current_id, current_auto_flat_table_name);

    END LOOP;

    CLOSE cur;

    UPDATE mamba_dim_encounter_type et
        JOIN mamba_dim_encounter_type_temp t
        ON et.encounter_type_id = t.encounter_type_id
    SET et.auto_flat_table_name = t.auto_flat_table_name
    WHERE et.incremental_record = 1;

    DROP TEMPORARY TABLE mamba_dim_encounter_type_temp;

END //

DELIMITER ;