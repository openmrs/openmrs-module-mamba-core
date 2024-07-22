-- $BEGIN

CALL sp_mamba_dim_orders_incremental_insert();
CALL sp_mamba_dim_orders_incremental_update();

-- $END
