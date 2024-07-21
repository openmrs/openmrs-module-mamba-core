-- $BEGIN

CALL sp_mamba_dim_person_name_incremental_insert();
CALL sp_mamba_dim_person_name_incremental_update();

-- $END