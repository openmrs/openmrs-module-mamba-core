-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept_datatype', 'mamba_dim_concept_datatype');
CALL sp_mamba_dim_concept_datatype_incremental_insert();
CALL sp_mamba_dim_concept_datatype_incremental_update();

-- $END
