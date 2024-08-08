-- $BEGIN

CALL sp_mamba_concept_metadata_incremental_insert();
CALL sp_mamba_concept_metadata_missing_columns_incremental_insert(); -- Update/insert table column metadata configs without table_columns json
CALL sp_mamba_concept_metadata_incremental_update();
CALL sp_mamba_concept_metadata_incremental_cleanup();

-- $END
