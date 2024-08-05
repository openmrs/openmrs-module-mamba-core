DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all_insert(
    IN openmrs_table VARCHAR(255)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE incremental_column_name VARCHAR(255);
    DECLARE column_list VARCHAR(500) DEFAULT 'incremental_table_pkey, ';
    DECLARE select_list VARCHAR(500) DEFAULT '';
    DECLARE pkey_column VARCHAR(255);

    DECLARE column_cursor CURSOR FOR
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'mamba_etl_incremental_columns_index_all';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Identify the primary key of the target table
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'mamba_source_db'
      AND TABLE_NAME = openmrs_table
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    -- Add the primary key to the select list
    SET select_list = CONCAT(select_list, pkey_column, ', ');

    OPEN column_cursor;

    column_loop:
    LOOP
        FETCH column_cursor INTO incremental_column_name;
        IF done THEN
            LEAVE column_loop;
        END IF;

        -- Check if the column exists in openmrs_table
        IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'mamba_source_db'
                     AND TABLE_NAME = openmrs_table
                     AND COLUMN_NAME = incremental_column_name) THEN
            SET column_list = CONCAT(column_list, incremental_column_name, ', ');
            SET select_list = CONCAT(select_list, incremental_column_name, ', ');
        END IF;
    END LOOP column_loop;

    CLOSE column_cursor;

    -- Remove the trailing comma and space
    SET column_list = LEFT(column_list, LENGTH(column_list) - 2);
    SET select_list = LEFT(select_list, LENGTH(select_list) - 2);

    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_all (', column_list, ') ',
            'SELECT ', select_list, ' FROM mamba_source_db.', openmrs_table
                      );

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;