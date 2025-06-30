-- $BEGIN

CALL sp_mamba_dim_encounter_diagnosis_create();
CALL sp_mamba_dim_encounter_diagnosis_insert();
CALL sp_mamba_dim_encounter_diagnosis_update();

-- $END
