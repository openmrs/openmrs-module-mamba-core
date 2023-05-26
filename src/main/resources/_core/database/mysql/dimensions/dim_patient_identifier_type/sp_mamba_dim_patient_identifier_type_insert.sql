-- $BEGIN

INSERT INTO mamba_dim_patient_identifier_type (patient_identifier_type_id,
                                               name,
                                               description)
SELECT patient_identifier_type_id,
       name,
       description
FROM patient_identifier_type c;

-- $END