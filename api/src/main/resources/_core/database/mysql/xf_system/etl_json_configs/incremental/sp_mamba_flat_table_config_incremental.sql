-- $BEGIN

CALL sp_mamba_flat_table_config_incremental_truncate();
CALL sp_mamba_flat_table_config_incremental_create();
CALL sp_mamba_flat_table_config_incremental_insert();
CALL sp_mamba_flat_table_config_incremental_update();

-- $END