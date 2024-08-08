-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept', 'mamba_dim_concept');
CALL sp_mamba_dim_concept_incremental_insert();
CALL sp_mamba_dim_concept_incremental_update();
CALL sp_mamba_dim_concept_incremental_cleanup();

-- $END
