-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('encounter_diagnosis', 'mamba_dim_encounter_diagnosis');
CALL sp_mamba_dim_encounter_diagnosis_incremental_insert();
CALL sp_mamba_dim_encounter_diagnosis_incremental_update();

-- $END