DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_all;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_all(
    IN target_table_name VARCHAR(255)
)
BEGIN

    CALL sp_mamba_etl_incremental_columns_index_all_create();
    CALL sp_mamba_etl_incremental_columns_index_all_truncate();
    CALL sp_mamba_etl_incremental_columns_index_all_insert(target_table_name);

END //

DELIMITER ;