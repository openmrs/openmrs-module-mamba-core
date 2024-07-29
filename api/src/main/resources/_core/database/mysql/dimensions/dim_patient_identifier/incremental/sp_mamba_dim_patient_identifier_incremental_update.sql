-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_patient_identifier mpi
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpi.patient_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.patient_identifier pi
    ON mpi.patient_id = pi.patient_id
SET mpi.patient_id         = pi.patient_id,
    mpi.identifier         = pi.identifier,
    mpi.identifier_type    = pi.identifier_type,
    mpi.preferred          = pi.preferred,
    mpi.location_id        = pi.location_id,
    mpi.patient_program_id = pi.patient_program_id,
    mpi.uuid               = pi.uuid,
    mpi.voided             = pi.voided,
    mpi.date_created       = pi.date_created,
    mpi.date_changed       = pi.date_changed,
    mpi.date_voided        = pi.date_voided,
    mpi.changed_by         = pi.changed_by,
    mpi.voided_by          = pi.voided_by,
    mpi.void_reason        = pi.void_reason,
    mpi.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END