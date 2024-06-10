-- $BEGIN
DECLARE starttime DATETIME;
SELECT  start_time INTO starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
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
                              date_created,
                              person_name_short,
                              person_name_long,
                              uuid,
                              voided,
                              flag)
SELECT psn.person_id,
       psn.birthdate,
       psn.birthdate_estimated,
       fn_mamba_age_calculator(birthdate, death_date)               AS age,
       psn.dead,
       psn.death_date,
       psn.deathdate_estimated,
       psn.gender,
       psn.date_created,
       CONCAT_WS(' ', prefix, given_name, middle_name, family_name) AS person_name_short,
       CONCAT_WS(' ', prefix, given_name, middle_name, family_name_prefix, family_name, family_name2,
                 family_name_suffix, degree) AS person_name_long,
       psn.uuid,
       psn.voided,
       1  flag
FROM mamba_source_db.person psn
         INNER JOIN mamba_dim_person_name pn
                    on psn.person_id = pn.person_id
WHERE pn.preferred = 1
  AND pn.voided = 0 AND  ca.date_created >= starttime;


-- Update only modified records
UPDATE mamba_dim_person p
    INNER JOIN mamba_source_db.person psn
        ON p.person_id = psn.person_id
    INNER JOIN mamba_source_db.person_name pn
        ON psn.person_id = pn.person_id
SET p.birthdate = psn.birthdate ,
    p.gender = psn.gender,
    p.age = fn_mamba_age_calculator(birthdate, death_date),
    p.date_created = psn.date_created,
    p.voided = psn.voided,
    p.dead = psn.dead,
    p.deathdate_estimated = psn.deathdate_estimated,
    p.person_name_short = CONCAT_WS(' ', prefix, given_name, middle_name, family_name),
    p.person_name_long = CONCAT_WS(' ', prefix, given_name, middle_name, family_name_prefix, family_name, family_name2,
    family_name_suffix, degree),
    p.flag = 2
WHERE c.date_changed >= starttime;



-- $END