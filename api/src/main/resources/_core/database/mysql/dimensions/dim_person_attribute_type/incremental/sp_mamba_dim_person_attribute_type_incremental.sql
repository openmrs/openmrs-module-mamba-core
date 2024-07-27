-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('person_attribute_type', 'mamba_dim_person_attribute_type');
CALL sp_mamba_dim_person_attribute_type_incremental_insert();
CALL sp_mamba_dim_person_attribute_type_incremental_update();

-- $END
