-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('users', 'mamba_dim_users', TRUE);

-- $END