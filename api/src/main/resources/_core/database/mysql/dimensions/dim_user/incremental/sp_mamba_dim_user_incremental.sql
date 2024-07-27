-- $BEGIN
CALL sp_mamba_etl_incremental_columns_index('users', 'mamba_dim_users');
CALL sp_mamba_dim_user_incremental_insert();
CALL sp_mamba_dim_user_incremental_update();
-- $END