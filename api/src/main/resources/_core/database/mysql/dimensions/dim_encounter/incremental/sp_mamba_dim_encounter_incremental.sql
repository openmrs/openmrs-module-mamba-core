-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('encounter', 'mamba_dim_encounter');
CALL sp_mamba_dim_encounter_incremental_insert();
CALL sp_mamba_dim_encounter_incremental_update();

-- $END
