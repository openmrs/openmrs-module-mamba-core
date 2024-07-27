-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_name', 'mamba_dim_person_name');
CALL sp_mamba_dim_person_name_incremental_insert();
CALL sp_mamba_dim_person_name_incremental_update();

-- $END
