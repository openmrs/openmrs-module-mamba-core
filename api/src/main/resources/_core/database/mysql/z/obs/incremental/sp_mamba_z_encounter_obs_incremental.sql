-- $BEGIN

CALL sp_mamba_z_encounter_obs_incremental_insert();
CALL sp_mamba_z_encounter_obs_incremental_update();

-- $END