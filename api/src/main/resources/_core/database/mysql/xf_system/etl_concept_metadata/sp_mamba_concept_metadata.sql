-- $BEGIN

CALL sp_mamba_concept_metadata_create();
CALL sp_mamba_concept_metadata_insert();
CALL sp_mamba_missing_table_column_names_insert(); -- Update/insert table column metadata configs without table_columns json
CALL sp_mamba_concept_metadata_update();
CALL sp_mamba_concept_metadata_cleanup();

-- $END
