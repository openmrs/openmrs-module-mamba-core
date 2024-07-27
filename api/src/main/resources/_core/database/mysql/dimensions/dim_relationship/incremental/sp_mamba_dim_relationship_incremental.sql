-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('relationship', 'mamba_dim_relationship');
CALL sp_mamba_dim_relationship_incremental_insert();
CALL sp_mamba_dim_relationship_incremental_update();

-- $END