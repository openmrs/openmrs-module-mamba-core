DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all_insert(
    IN openmrs_table VARCHAR(255)
)
BEGIN

    SET @insert_sql = CONCAT(
            'INSERT INTO mamba_etl_incremental_columns_index_all (mamba_etl_database_event_id, incremental_table_pkey, database_operation)
    SELECT de.id, de.incremental_table_pkey, de.database_operation
    FROM _mamba_etl_database_event de
    WHERE table_name = ''', openmrs_table, '''
    ORDER BY de.id ASC');

    PREPARE stmt FROM @insert_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;