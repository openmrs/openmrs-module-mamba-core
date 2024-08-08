-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('encounter_type', 'mamba_dim_encounter_type');
CALL sp_mamba_dim_encounter_type_incremental_insert();
CALL sp_mamba_dim_encounter_type_incremental_update();

-- $END
