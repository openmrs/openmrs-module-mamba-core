DROP PROCEDURE IF EXISTS sp_mamba_etl_incremental_columns_index;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_incremental_columns_index(
    IN openmrs_table_name VARCHAR(255),
    IN mamba_table_name VARCHAR(255)
)
BEGIN

    CALL sp_mamba_etl_incremental_columns_index_all(openmrs_table_name);
    CALL sp_mamba_etl_incremental_columns_index_new(mamba_table_name);
    CALL sp_mamba_etl_incremental_columns_index_modified(mamba_table_name);

END //

DELIMITER ;


