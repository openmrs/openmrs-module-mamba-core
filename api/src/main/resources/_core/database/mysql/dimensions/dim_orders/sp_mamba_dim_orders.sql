-- $BEGIN

CALL sp_mamba_dim_orders_create();
CALL sp_mamba_dim_orders_insert();
CALL sp_mamba_dim_orders_update();

-- $END
