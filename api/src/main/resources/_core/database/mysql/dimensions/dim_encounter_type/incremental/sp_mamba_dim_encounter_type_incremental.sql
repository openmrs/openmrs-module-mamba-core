-- $BEGIN

CALL sp_mamba_dim_encounter_type_incremental_insert();
CALL sp_mamba_dim_encounter_type_incremental_update();

-- $END
