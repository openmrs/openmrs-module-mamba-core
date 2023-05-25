-- $BEGIN

INSERT INTO mamba_dim_patient_identifier_type (patient_identifier_type_id,
                                               name)
SELECT patient_identifier_type_id,
       name
FROM patient_identifier_type c;

-- $END