-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_users (user_id,
                             system_id,
                             username,
                             creator,
                             person_id,
                             uuid,
                             email,
                             retired,
                             date_created,
                             date_changed,
                             changed_by,
                             date_retired,
                             retired_by,
                             retire_reason,
                             incremental_record)
SELECT user_id,
       system_id,
       username,
       creator,
       person_id,
       uuid,
       email,
       retired,
       date_created,
       date_changed,
       changed_by,
       date_retired,
       retired_by,
       retire_reason,
       1
FROM mamba_source_db.users u
WHERE u.user_id NOT IN (SELECT DISTINCT (user_id) FROM mamba_dim_users)
  AND u.date_created >= @starttime;

-- $END