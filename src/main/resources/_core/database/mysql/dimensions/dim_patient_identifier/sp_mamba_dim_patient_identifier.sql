-- $BEGIN

CALL sp_mamba_dim_patient_identifier_create();
CALL sp_mamba_dim_patient_identifier_insert();
CALL sp_mamba_dim_patient_identifier_update();

-- $END
