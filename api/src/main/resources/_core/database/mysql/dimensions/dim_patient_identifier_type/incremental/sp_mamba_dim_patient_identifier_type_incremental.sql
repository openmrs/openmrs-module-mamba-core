-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('patient_identifier_type', 'mamba_dim_patient_identifier_type');
CALL sp_mamba_dim_patient_identifier_type_incremental_insert();
CALL sp_mamba_dim_patient_identifier_type_incremental_update();

-- $END
