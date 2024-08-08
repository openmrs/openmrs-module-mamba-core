-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('orders', 'mamba_dim_orders');
CALL sp_mamba_dim_orders_incremental_insert();
CALL sp_mamba_dim_orders_incremental_update();

-- $END
