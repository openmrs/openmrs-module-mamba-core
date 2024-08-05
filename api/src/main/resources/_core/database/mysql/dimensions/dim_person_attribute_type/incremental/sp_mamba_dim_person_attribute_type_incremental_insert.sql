-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('person_attribute_type', 'mamba_dim_person_attribute_type', TRUE);

-- $END