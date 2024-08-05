-- $BEGIN

-- Insert only new records
CALL sp_mamba_dim_table_insert('concept_answer', 'mamba_dim_concept_answer', TRUE);

-- $END