-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('patient_identifier', 'mamba_dim_patient_identifier');
CALL sp_mamba_dim_patient_identifier_incremental_insert();
CALL sp_mamba_dim_patient_identifier_incremental_update();

-- $END
