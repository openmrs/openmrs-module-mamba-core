-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('concept_datatype', 'mamba_dim_concept_datatype', TRUE);

-- $END