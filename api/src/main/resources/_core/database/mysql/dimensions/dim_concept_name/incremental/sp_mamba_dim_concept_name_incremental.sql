-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept_name', 'mamba_dim_concept_name');
CALL sp_mamba_dim_concept_name_incremental_insert();
CALL sp_mamba_dim_concept_name_incremental_update();

-- $END
