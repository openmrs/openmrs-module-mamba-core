-- $BEGIN

INSERT INTO mamba_dim_patient_identifier_type (patient_identifier_type_id,
                                               name,
                                               description,
                                               uuid,
                                               date_created,
                                               date_changed,
                                               changed_by,
                                               retired,
                                               retired_by,
                                               retire_reason)
SELECT patient_identifier_type_id,
       name,
       description,
       uuid,
       date_created,
       date_changed,
       changed_by,
       retired,
       retired_by,
       retire_reason
FROM mamba_source_db.patient_identifier_type;

-- $END