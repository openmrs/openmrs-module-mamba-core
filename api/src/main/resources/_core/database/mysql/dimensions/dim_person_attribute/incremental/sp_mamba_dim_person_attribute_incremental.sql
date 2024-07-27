-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_attribute', 'mamba_dim_person_attribute');
CALL sp_mamba_dim_person_attribute_incremental_insert();
CALL sp_mamba_dim_person_attribute_incremental_update();

-- $END
