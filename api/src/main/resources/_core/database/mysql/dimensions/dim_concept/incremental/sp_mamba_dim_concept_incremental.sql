-- $BEGIN

CALL sp_mamba_dim_concept_incremental_insert();
CALL sp_mamba_dim_concept_incremental_update();

-- $END
