-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_address', 'mamba_dim_person_address');
CALL sp_mamba_dim_person_address_incremental_insert();
CALL sp_mamba_dim_person_address_incremental_update();

-- $END
