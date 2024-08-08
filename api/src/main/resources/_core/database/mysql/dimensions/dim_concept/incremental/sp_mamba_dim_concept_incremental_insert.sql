-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('concept', 'mamba_dim_concept', TRUE);

-- $END