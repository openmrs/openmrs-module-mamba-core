DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_modified_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_modified_insert(
    IN mamba_table_name VARCHAR(255)
)
BEGIN
    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_modified (incremental_table_pkey) ',
            'SELECT DISTINCT incremental_table_pkey ',
            'FROM mamba_etl_incremental_columns_index_all ',
            'WHERE database_operation = ''UPDATE''');

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;