-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person', 'mamba_dim_person');
CALL sp_mamba_dim_person_incremental_insert();
CALL sp_mamba_dim_person_incremental_update();

-- $END
