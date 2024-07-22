-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Modified Persons
UPDATE mamba_dim_person p
    INNER JOIN mamba_source_db.person psn
    ON p.person_id = psn.person_id
    INNER JOIN mamba_dim_person_name pn
    on psn.person_id = pn.person_id
SET p.birthdate           = psn.birthdate,
    p.birthdate_estimated = psn.birthdate_estimated,
    p.age                 = fn_mamba_age_calculator(psn.birthdate, psn.death_date),
    p.dead                = psn.dead,
    p.death_date          = psn.death_date,
    p.deathdate_estimated = psn.deathdate_estimated,
    p.gender              = psn.gender,
    p.person_name_short   = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name),
    p.person_name_long    = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name_prefix,
                                      pn.family_name,
                                      pn.family_name2,
                                      pn.family_name_suffix, pn.degree),
    p.uuid                = psn.uuid,
    p.date_created        = psn.date_created,
    p.date_changed        = psn.date_changed,
    p.changed_by          = psn.changed_by,
    p.date_voided         = psn.date_voided,
    p.voided              = psn.voided,
    p.voided_by           = psn.voided_by,
    p.void_reason         = psn.void_reason,
    p.incremental_record  = 1
WHERE psn.date_changed >= @starttime
   OR (psn.voided = 1 AND psn.date_voided >= @starttime);

-- $END