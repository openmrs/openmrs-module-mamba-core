-- $BEGIN

CALL sp_mamba_dim_relationship_incremental_insert();
CALL sp_mamba_dim_relationship_incremental_update();

-- $END