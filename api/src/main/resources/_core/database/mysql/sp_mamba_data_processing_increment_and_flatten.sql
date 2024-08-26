DROP PROCEDURE IF EXISTS sp_mamba_data_processing_increment_and_flatten;

DELIMITER //

CREATE PROCEDURE sp_mamba_data_processing_increment_and_flatten()

BEGIN

    CALL sp_mamba_dim_location_incremental;

    CALL sp_mamba_dim_patient_identifier_type_incremental;

    CALL sp_mamba_dim_concept_datatype_incremental;

    CALL sp_mamba_dim_concept_name_incremental;

    CALL sp_mamba_dim_concept_incremental;

    CALL sp_mamba_dim_concept_answer_incremental;

    CALL sp_mamba_dim_encounter_type_incremental;

    CALL sp_mamba_flat_table_config_incremental;

    CALL sp_mamba_concept_metadata_incremental;

    CALL sp_mamba_dim_encounter_incremental;

    CALL sp_mamba_dim_person_name_incremental;

    CALL sp_mamba_dim_person_incremental;

    CALL sp_mamba_dim_person_attribute_type_incremental;

    CALL sp_mamba_dim_person_attribute_incremental;

    CALL sp_mamba_dim_person_address_incremental;

    CALL sp_mamba_dim_user_incremental;

    CALL sp_mamba_dim_relationship_incremental;

    CALL sp_mamba_dim_patient_identifier_incremental;

    CALL sp_mamba_dim_orders_incremental;

    -- incremental inserts into the mamba_z_encounter_obs table only
    CALL sp_mamba_z_encounter_obs_incremental;

    CALL sp_mamba_flat_table_incremental_create_all;

    -- create and insert into flat tables whose columns or table names have been modified/added (determined by json_data hash)
    CALL sp_mamba_flat_table_incremental_insert_all;

    -- insert from mamba_z_encounter_obs into the flat table OBS that are either MODIFIED or CREATED/NEW
    -- (Deletes and inserts an entire Encounter (by id) if one of the obs is modified)
    CALL sp_mamba_flat_table_incremental_update_encounter;

    CALL sp_mamba_reset_incremental_update_flag_all;

END //

DELIMITER ;