-- $BEGIN

SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_users
(
                            user_id,
                            system_id,
                            username,
                            creator,
                            date_created,
                            changed_by,
                            date_changed,
                            person_id,
                            retired,
                            retired_by,
                            date_retired,
                            retire_reason,
                            uuid,
                            email,
                            flag)
SELECT
                            user_id,
                            system_id,
                            username,
                            creator,
                            date_created,
                            changed_by,
                            date_changed,
                            person_id,
                            retired,
                            retired_by,
                            date_retired,
                            retire_reason,
                            uuid,
                            email,
                            1  flag
FROM mamba_source_db.users u
WHERE u.date_created >= @starttime;


-- Update only modified records
UPDATE mamba_dim_user u
    INNER JOIN mamba_source_db.user us
        ON u.user_id = us.user_id
    SET u.username = us.username ,
        u.creator = us.creator,
        u.retired = us.retired,
        u.date_changed = us.date_changed,
        u.changed_by = us.changed_by,
        u.flag = 2
WHERE us.date_changed >= @starttime;



-- $END