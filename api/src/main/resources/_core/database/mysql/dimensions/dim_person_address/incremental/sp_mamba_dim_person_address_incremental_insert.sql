-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('person_address', 'mamba_dim_person_address', TRUE);

-- $END