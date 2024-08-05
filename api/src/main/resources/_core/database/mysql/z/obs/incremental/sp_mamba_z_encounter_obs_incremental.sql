-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('obs', 'mamba_z_encounter_obs');
CALL sp_mamba_z_encounter_obs_incremental_insert();
CALL sp_mamba_z_encounter_obs_incremental_update();

-- $END