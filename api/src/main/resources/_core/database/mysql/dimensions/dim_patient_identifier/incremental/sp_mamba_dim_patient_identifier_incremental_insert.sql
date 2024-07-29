-- $BEGIN

-- Insert only new Records
CALL sp_mamba_dim_table_insert('patient_identifier', 'mamba_dim_patient_identifier', TRUE);

-- $END