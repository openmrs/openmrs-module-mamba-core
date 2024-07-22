-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_relationship (relationship_id,
                                    person_a,
                                    relationship,
                                    person_b,
                                    start_date,
                                    end_date,
                                    creator,
                                    uuid,
                                    date_created,
                                    date_changed,
                                    changed_by,
                                    voided,
                                    voided_by,
                                    date_voided,
                                    void_reason,
                                    incremental_record)
SELECT relationship_id,
       person_a,
       relationship,
       person_b,
       start_date,
       end_date,
       creator,
       uuid,
       date_created,
       date_changed,
       changed_by,
       voided,
       voided_by,
       date_voided,
       void_reason,
       1
FROM mamba_source_db.relationship r
WHERE r.relationship_id NOT IN (SELECT DISTINCT (relationship_id) FROM mamba_dim_relationship)
  AND r.date_created >= @starttime;

-- $END