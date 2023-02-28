-- $BEGIN

CALL sp_xf_system_drop_all_tables_in_schema('openmrs_working');

CALL sp_mamba_dim_concept_datatype;

CALL sp_mamba_dim_concept_answer;

CALL sp_mamba_dim_concept_name;

CALL sp_mamba_dim_concept;

CALL sp_mamba_dim_encounter_type;

CALL sp_mamba_dim_encounter;

CALL sp_mamba_dim_concept_metadata;

CALL sp_mamba_dim_person;

CALL sp_mamba_dim_person_name;

CALL sp_mamba_dim_person_address;

CALL sp_dim_client;

CALL sp_mamba_z_tables;

-- $END