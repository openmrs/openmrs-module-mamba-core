-- $BEGIN

INSERT INTO mamba_dim_patient_identifier (patient_id,
                                          identifier,
                                          identifier_type,
                                          preferred,
                                          location_id,
                                          date_created,
                                          voided)
SELECT patient_id,
       identifier,
       identifier_type,
       preferred,
       location_id,
       date_created,
       voided
FROM patient_identifier;

-- $END