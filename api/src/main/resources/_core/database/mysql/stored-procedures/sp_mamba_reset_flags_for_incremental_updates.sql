DROP PROCEDURE IF EXISTS sp_mamba_reset_flags_for_incremental_updates;

DELIMITER //

CREATE PROCEDURE sp_mamba_reset_flags_for_incremental_updates()
BEGIN

    update mamba_dim_concept set flag  = NULL  where flag in (1,2);

    update mamba_dim_concept_answer set flag  = NULL  where flag in (1,2);

    update mamba_dim_person set flag  = NULL  where flag in (1,2);

    update mamba_dim_users set flag  = NULL  where flag in (1,2);

    update mamba_dim_encounter set flag  = NULL  where flag in (1,2);

    update mamba_dim_encounter_type set flag  = NULL  where flag in (1,2);

    update mamba_dim_relationship set flag  = NULL  where flag in (1,2);

    update mamba_dim_orders set flag  = NULL  where flag in (1,2);

    update mamba_flat_table_config set flag  = NULL  where flag in (1,2);

    update mamba_z_encounter_obs set flag  = NULL  where flag in (1,2);


END //

DELIMITER ;
