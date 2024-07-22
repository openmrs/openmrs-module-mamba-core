-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Update only modified records
UPDATE mamba_dim_relationship r
    INNER JOIN mamba_source_db.relationship rel
    ON r.relationship_id = rel.relationship_id
SET r.relationship       = rel.relationship,
    r.person_a           = rel.person_a,
    r.relationship       = rel.relationship,
    r.person_b           = rel.person_b,
    r.start_date         = rel.start_date,
    r.end_date           = rel.end_date,
    r.creator            = rel.creator,
    r.uuid               = rel.uuid,
    r.date_created       = rel.date_created,
    r.date_changed       = rel.date_changed,
    r.changed_by         = rel.changed_by,
    r.voided             = rel.voided,
    r.voided_by          = rel.voided_by,
    r.date_voided        = rel.date_voided,
    r.incremental_record = 1
WHERE rel.date_changed >= @starttime;


-- $END