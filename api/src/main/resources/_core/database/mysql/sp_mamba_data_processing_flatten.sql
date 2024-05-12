-- $BEGIN
-- CALL sp_xf_system_drop_all_tables_in_schema($target_database);
CALL sp_xf_system_drop_all_tables_in_schema();

CALL sp_mamba_dim_locale;

CALL sp_mamba_dim_table_partition;

CALL sp_mamba_dim_location;

CALL sp_mamba_dim_patient_identifier_type;

CALL sp_mamba_dim_concept_datatype;

CALL sp_mamba_dim_concept_answer;

CALL sp_mamba_dim_concept_name;

CALL sp_mamba_dim_concept;

CALL sp_mamba_dim_encounter_type;

CALL sp_mamba_dim_json_create;

CALL sp_mamba_dim_concept_metadata;

CALL sp_mamba_dim_report_definition;

CALL sp_mamba_dim_encounter;

CALL sp_mamba_dim_person_name;

CALL sp_mamba_dim_person;

CALL sp_mamba_dim_person_address;

CALL sp_mamba_dim_user;

CALL sp_mamba_dim_relationship;

CALL sp_mamba_dim_patient_identifier;

CALL sp_mamba_dim_orders;

CALL sp_mamba_dim_agegroup;

CALL sp_mamba_z_encounter_obs;

CALL sp_mamba_dim_obs_group;

CALL sp_mamba_flat_encounter_table_create_all;

CALL sp_mamba_flat_encounter_table_insert_all;

CALL sp_mamba_flat_encounter_obs_group_table_create_all;

CALL sp_mamba_flat_encounter_obs_group_table_insert_all;
-- $END