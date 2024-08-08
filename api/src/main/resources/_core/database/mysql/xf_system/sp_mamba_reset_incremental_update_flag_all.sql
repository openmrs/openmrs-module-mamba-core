-- $BEGIN

-- Given a table name, this procedure will reset the incremental_record column to 0 for all rows where the incremental_record is 1.
-- This is useful when we want to re-run the incremental updates for a table.

CALL sp_mamba_reset_incremental_update_flag('mamba_dim_location');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_patient_identifier_type');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept_datatype');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept_name');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_concept_answer');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_encounter_type');
CALL sp_mamba_reset_incremental_update_flag('mamba_flat_table_config');
CALL sp_mamba_reset_incremental_update_flag('mamba_concept_metadata');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_encounter');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_name');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_attribute_type');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_attribute');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_person_address');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_users');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_relationship');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_patient_identifier');
CALL sp_mamba_reset_incremental_update_flag('mamba_dim_orders');
CALL sp_mamba_reset_incremental_update_flag('mamba_z_encounter_obs');

-- $END