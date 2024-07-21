-- $BEGIN
SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

INSERT INTO mamba_dim_patient_identifier_type (patient_identifier_type_id,
                                               name,
                                               description,
                                               uuid,
                                               date_changed,
                                               changed_by,
                                               voided_by,
                                               date_voided,
                                               void_reason,
                                               incremental_record)
SELECT patient_identifier_type_id,
       name,
       description,
       uuid,
       date_changed,
       changed_by,
       voided_by,
       date_voided,
       void_reason,
       1
FROM mamba_source_db.patient_identifier_type
where patient_identifier_type_id NOT IN (SELECT patient_identifier_type_id FROM mamba_dim_patient_identifier_type)
  AND date_created >= @starttime;

-- $END