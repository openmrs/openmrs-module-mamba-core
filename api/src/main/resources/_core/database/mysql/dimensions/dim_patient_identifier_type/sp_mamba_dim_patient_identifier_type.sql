-- $BEGIN

CALL sp_mamba_dim_patient_identifier_type_create();
CALL sp_mamba_dim_patient_identifier_type_insert();
CALL sp_mamba_dim_patient_identifier_type_update();

-- $END