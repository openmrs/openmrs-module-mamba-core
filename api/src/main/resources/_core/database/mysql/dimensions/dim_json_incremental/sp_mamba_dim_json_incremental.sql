-- $BEGIN

CALL sp_mamba_dim_json_incremental_create();
CALL sp_mamba_dim_json_incremental_insert();
CALL sp_mamba_dim_json_incremental_update();

-- $END