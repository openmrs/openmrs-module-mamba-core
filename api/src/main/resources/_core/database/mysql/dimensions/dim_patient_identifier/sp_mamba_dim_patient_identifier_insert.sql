-- $BEGIN

INSERT INTO mamba_dim_patient_identifier (patient_id,
                                          identifier,
                                          identifier_type,
                                          preferred,
                                          location_id,
                                          date_created,
                                          uuid,
                                          voided)
SELECT patient_id,
       identifier,
       identifier_type,
       preferred,
       location_id,
       date_created,
       uuid,
       voided
FROM mamba_source_db.patient_identifier;

-- $END