-- $BEGIN

CALL sp_mamba_dim_person_incremental_insert();
CALL sp_mamba_dim_person_incremental_update();

-- $END
