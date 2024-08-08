DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_modified_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_modified_insert(
    IN mamba_table_name VARCHAR(255)
)
BEGIN
    DECLARE incremental_start_time DATETIME;
    DECLARE pkey_column VARCHAR(255);

    -- Identify the primary key of the 'mamba_table_name'
    SELECT COLUMN_NAME
    INTO pkey_column
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = mamba_table_name
      AND COLUMN_KEY = 'PRI'
    LIMIT 1;

    SET incremental_start_time = (SELECT start_time
                                  FROM _mamba_etl_schedule sch
                                  WHERE end_time IS NOT NULL
                                    AND transaction_status = 'COMPLETED'
                                  ORDER BY id DESC
                                  LIMIT 1);

    -- Insert only records that are NOT in the mamba ETL table
    -- and were created after the last ETL run time (start_time)
    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_modified (incremental_table_pkey) ',
            'SELECT DISTINCT incremental_table_pkey ',
            'FROM mamba_etl_incremental_columns_index_all ',
            'WHERE date_changed >= ?',
            ' OR (voided = 1 AND date_voided >= ?)',
            ' OR (retired = 1 AND date_retired >= ?)');

    PREPARE stmt FROM @insert_sql;
    SET @incremental_start_time = incremental_start_time;
    EXECUTE stmt USING @incremental_start_time, @incremental_start_time, @incremental_start_time;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;