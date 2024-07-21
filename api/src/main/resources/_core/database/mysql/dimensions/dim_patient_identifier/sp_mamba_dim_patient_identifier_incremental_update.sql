-- $BEGIN

SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

UPDATE mamba_dim_patient_identifier mpi
    INNER JOIN mamba_source_db.patient_identifier pi
ON mpi.patient_id = pi.patient_id
    SET
        mpi.identifier = pi.identifier,
        mpi.identifier_type = pi.identifier_type,
        mpi.preferred = pi.preferred,
        mpi.location_id = pi.location_id,
        mpi.date_created = pi.date_created,
        mpi.uuid = pi.uuid,
        mpi.voided = pi.voided,
        mpi.date_changed = pi.date_changed,
        mpi.changed_by = pi.changed_by,
        mpi.voided_by = pi.voided_by,
        mpi.date_voided = pi.date_voided,
        mpi.void_reason = pi.void_reason,
        mpi.incremental_record = 1
WHERE pi.date_changed >= @starttime;

-- $END