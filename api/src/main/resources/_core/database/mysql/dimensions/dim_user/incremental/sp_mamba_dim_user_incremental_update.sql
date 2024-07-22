-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Modified Users
UPDATE mamba_dim_users u
    INNER JOIN mamba_source_db.users us
    ON u.user_id = us.user_id
SET u.system_id          = us.system_id,
    u.username           = us.username,
    u.creator            = us.creator,
    u.person_id          = us.person_id,
    u.uuid               = us.uuid,
    u.email              = us.email,
    u.retired            = us.retired,
    u.date_created       = us.date_created,
    u.date_changed       = us.date_changed,
    u.changed_by         = us.changed_by,
    u.date_retired       = us.date_retired,
    u.retired_by         = us.retired_by,
    u.retire_reason      = us.retire_reason,
    u.incremental_record = 1
WHERE us.date_changed >= @starttime
   OR (us.retired = 1 AND us.date_retired >= @starttime);

-- $END