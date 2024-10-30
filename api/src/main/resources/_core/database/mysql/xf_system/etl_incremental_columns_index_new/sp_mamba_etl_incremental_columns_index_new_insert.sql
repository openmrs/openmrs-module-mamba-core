DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_new_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_new_insert(
    IN mamba_table_name VARCHAR(255)
)
BEGIN

    DECLARE pkey_column VARCHAR(255);

    -- Identify the primary key of the 'mamba_table_name'
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = mamba_table_name
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_new (incremental_table_pkey) ',
            'SELECT DISTINCT incremental_table_pkey ',
            'FROM mamba_etl_incremental_columns_index_all ',
            'WHERE database_operation = ''CREATE'' ',
            'AND incremental_table_pkey
                NOT IN (SELECT ', pkey_column, ' FROM ', mamba_table_name, ')');

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;