-- $BEGIN

CALL sp_mamba_dim_table_partition_create();
CALL sp_mamba_dim_table_partition_insert();

-- $END