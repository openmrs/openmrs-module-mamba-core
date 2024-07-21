-- $BEGIN

    CALL sp_mamba_dim_location_incremental_insert();
    CALL sp_mamba_dim_location_incremental_update();

-- $END