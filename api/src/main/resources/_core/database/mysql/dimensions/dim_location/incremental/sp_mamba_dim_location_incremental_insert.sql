-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('location', 'mamba_dim_location', TRUE);

-- $END