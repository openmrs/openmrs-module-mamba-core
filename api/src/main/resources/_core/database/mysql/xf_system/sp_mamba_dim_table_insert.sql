DROP PROCEDURE IF EXISTS sp_mamba_dim_table_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_dim_table_insert(
    IN openmrs_table VARCHAR(255),
    IN mamba_table VARCHAR(255),
    IN is_incremental BOOLEAN
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tbl_column_name VARCHAR(255);
    DECLARE column_list VARCHAR(500) DEFAULT '';
    DECLARE select_list VARCHAR(500) DEFAULT '';
    DECLARE pkey_column VARCHAR(255);
    DECLARE join_clause VARCHAR(500) DEFAULT '';

    DECLARE column_cursor CURSOR FOR
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = mamba_table;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Identify the primary key of the mamba_source_db table
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'mamba_source_db'
      AND TABLE_NAME = openmrs_table
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    SET column_list = CONCAT(column_list, 'incremental_record', ', ');
    IF is_incremental THEN
        SET select_list = CONCAT(select_list, 1, ', ');
    ELSE
        SET select_list = CONCAT(select_list, 0, ', ');
    END IF;

    OPEN column_cursor;

    column_loop:
    LOOP
        FETCH column_cursor INTO tbl_column_name;
        IF done THEN
            LEAVE column_loop;
        END IF;

        -- Check if the column exists in openmrs_table
        IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'mamba_source_db'
                     AND TABLE_NAME = openmrs_table
                     AND COLUMN_NAME = tbl_column_name) THEN
            SET column_list = CONCAT(column_list, tbl_column_name, ', ');
            SET select_list = CONCAT(select_list, tbl_column_name, ', ');
        END IF;
    END LOOP column_loop;

    CLOSE column_cursor;

    -- Remove the trailing comma and space
    SET column_list = LEFT(column_list, CHAR_LENGTH(column_list) - 2);
    SET select_list = LEFT(select_list, CHAR_LENGTH(select_list) - 2);

    -- Set the join clause if it is an incremental insert
    IF is_incremental THEN
        SET join_clause = CONCAT(
                ' INNER JOIN mamba_etl_incremental_columns_index_new ic',
                ' ON tb.', pkey_column, ' = ic.incremental_table_pkey');
    END IF;

    SET @insert_sql = CONCAT(
            'INSERT INTO ', mamba_table, ' (', column_list, ') ',
            'SELECT ', select_list,
            ' FROM mamba_source_db.', openmrs_table, ' tb',
            join_clause, ';');

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;