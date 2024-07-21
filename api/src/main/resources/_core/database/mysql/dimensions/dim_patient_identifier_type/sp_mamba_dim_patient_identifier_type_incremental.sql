-- $BEGIN

CALL sp_mamba_dim_patient_identifier_type_incremental_insert();
CALL sp_mamba_dim_patient_identifier_type_incremental_update();

-- $END