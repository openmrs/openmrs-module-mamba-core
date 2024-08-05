DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index_modified;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index_modified(
    IN mamba_table_name VARCHAR(255)
)
BEGIN

    CALL sp_mamba_etl_incremental_columns_index_modified_create();
    CALL sp_mamba_etl_incremental_columns_index_modified_truncate();
    CALL sp_mamba_etl_incremental_columns_index_modified_insert(mamba_table_name);

END //

DELIMITER ;