-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('conditions', 'mamba_dim_conditions');
CALL sp_mamba_dim_conditions_incremental_insert();
CALL sp_mamba_dim_conditions_incremental_update();

-- $END