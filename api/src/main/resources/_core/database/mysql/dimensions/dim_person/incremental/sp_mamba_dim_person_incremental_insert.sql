-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_person (person_id,
                              birthdate,
                              birthdate_estimated,
                              age,
                              dead,
                              death_date,
                              deathdate_estimated,
                              gender,
                              person_name_short,
                              person_name_long,
                              uuid,
                              date_created,
                              date_changed,
                              changed_by,
                              date_voided,
                              voided,
                              voided_by,
                              void_reason,
                              incremental_record)
SELECT psn.person_id,
       psn.birthdate,
       psn.birthdate_estimated,
       fn_mamba_age_calculator(birthdate, death_date)               AS age,
       psn.dead,
       psn.death_date,
       psn.deathdate_estimated,
       psn.gender,
       CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name) AS person_name_short,
       CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name_prefix, pn.family_name, pn.family_name2,
                 pn.family_name_suffix, pn.degree)                              AS person_name_long,
       psn.uuid,
       psn.date_created,
       psn.date_changed,
       psn.changed_by,
       psn.date_voided,
       psn.voided,
       psn.voided_by,
       psn.void_reason,
       1
FROM mamba_source_db.person psn
         INNER JOIN mamba_dim_person_name pn
                    on psn.person_id = pn.person_id
WHERE pn.preferred = 1
  AND pn.voided = 0
  AND psn.date_created >= @starttime;

-- $END