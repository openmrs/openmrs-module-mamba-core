-- $BEGIN

SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;


UPDATE mamba_dim_person_name mdpn
    INNER JOIN  mamba_source_db.person_name pn
ON pn.person_name_id = mdpn.person_name_id
    SET mdpn.given_name = pn.given_name,
        mdpn.middle_name = pn.middle_name,
        mdpn.family_name = pn.family_name,
        mdpn.voided = pn.voided,
        mdpn.voided_by = pn.voided_by,
        mdpn.void_reason = pn.void_reason,
        mdpn.date_changed = pn.date_changed,
        mdpn.changed_by = pn.changed_by,
        mdpn.incremental_record = 1
WHERE pn.date_changed >= @starttime;

-- $END