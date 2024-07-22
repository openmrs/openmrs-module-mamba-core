-- $BEGIN

CALL sp_mamba_dim_encounter_incremental_insert();
CALL sp_mamba_dim_encounter_incremental_update();

-- $END
