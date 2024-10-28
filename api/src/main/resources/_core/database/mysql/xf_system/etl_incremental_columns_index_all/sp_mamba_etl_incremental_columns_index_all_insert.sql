DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all_insert(
    IN openmrs_table VARCHAR(255)
)
BEGIN
    START TRANSACTION;

    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_all
             SELECT * FROM _mamba_etl_database_event
             WHERE table_name = ''', openmrs_table, ''' ORDER BY id ASC');

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    COMMIT;
END //

DELIMITER ;