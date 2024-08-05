-- $BEGIN

CALL sp_mamba_dim_encounter_type_create();
CALL sp_mamba_dim_encounter_type_insert();
CALL sp_mamba_dim_encounter_type_update();
CALL sp_mamba_dim_encounter_type_cleanup();

-- $END