-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('location', 'mamba_dim_location');
CALL sp_mamba_dim_location_incremental_insert();
CALL sp_mamba_dim_location_incremental_update();

-- $END
