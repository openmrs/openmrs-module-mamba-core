-- $BEGIN

CALL sp_mamba_dim_json_create();
CALL sp_mamba_dim_json_insert();
CALL sp_mamba_dim_json_update();

-- $END