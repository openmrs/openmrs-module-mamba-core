-- $BEGIN

SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;


UPDATE mamba_dim_patient_identifier_type mdpit
    INNER JOIN  mamba_source_db.patient_identifier_type pit
ON pit.patient_identifier_type_id = mdpit.patient_identifier_type_id
    SET  mdpit.name = pit.name,
        mdpit.retired = pit.retired,
        mdpit.retired_by = pit.retired_by,
        mdpit.retire_reason = pit.retire_reason,
        mdpit.date_changed = pit.date_changed,
        mdpit.changed_by = pit.changed_by,
        mdpit.incremental_record = 1
WHERE pit.date_changed >= @starttime;

-- $END