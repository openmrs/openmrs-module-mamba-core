-- $BEGIN

INSERT INTO mamba_dim_patient_identifier_type (patient_identifier_type_id,
                                               name,
                                               description,
                                               uuid)
SELECT patient_identifier_type_id,
       name,
       description,
       uuid
FROM mamba_source_db.patient_identifier_type;

-- $END