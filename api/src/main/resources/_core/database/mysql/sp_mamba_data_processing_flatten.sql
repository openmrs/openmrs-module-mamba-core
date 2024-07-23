-- $BEGIN
-- CALL sp_xf_system_drop_all_tables_in_schema($target_database);

CALL sp_xf_system_drop_all_tables_in_schema;

CALL sp_mamba_create_error_log_table();

CALL sp_mamba_dim_locale;

CALL sp_mamba_etl_user_settings;

CALL sp_mamba_dim_location;

CALL sp_mamba_dim_patient_identifier_type;

CALL sp_mamba_dim_concept_datatype;

CALL sp_mamba_dim_concept_name; -- ok

CALL sp_mamba_dim_concept; -- ok

CALL sp_mamba_dim_concept_answer; -- ok

CALL sp_mamba_dim_encounter_type; -- ok

CALL sp_mamba_dim_json_create;

CALL sp_mamba_dim_concept_metadata;

CALL sp_mamba_dim_report_definition;

CALL sp_mamba_dim_encounter; -- ok

CALL sp_mamba_dim_person_name; -- ok

CALL sp_mamba_dim_person; -- ok

CALL sp_mamba_dim_person_attribute;

CALL sp_mamba_dim_person_attribute_type;

CALL sp_mamba_dim_person_address;

CALL sp_mamba_dim_user; -- ok

CALL sp_mamba_dim_relationship; -- ok

CALL sp_mamba_dim_patient_identifier;

CALL sp_mamba_dim_orders; -- ok

CALL sp_mamba_dim_agegroup;

CALL sp_mamba_z_encounter_obs;

CALL sp_mamba_dim_obs_group;

CALL sp_mamba_flat_encounter_table_create_all;

CALL sp_mamba_flat_encounter_table_insert_all;

CALL sp_mamba_flat_encounter_obs_group_table_create_all;

CALL sp_mamba_flat_encounter_obs_group_table_insert_all;

-- $END