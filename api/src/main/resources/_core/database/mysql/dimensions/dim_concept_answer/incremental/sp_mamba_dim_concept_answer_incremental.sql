-- $BEGIN

CALL sp_mamba_etl_incremental_columns_index('concept_answer', 'mamba_dim_concept_answer');
CALL sp_mamba_dim_concept_answer_incremental_insert();
CALL sp_mamba_dim_concept_answer_incremental_update();

-- $END
