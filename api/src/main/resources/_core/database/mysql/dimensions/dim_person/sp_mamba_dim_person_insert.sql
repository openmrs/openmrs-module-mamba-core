-- $BEGIN

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
                              voided)

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
                 family_name_suffix, degree)
                                                                    AS person_name_long,
       psn.uuid,
       psn.voided
FROM person psn
         INNER JOIN mamba_dim_person_name pn
                    on psn.person_id = pn.person_id
WHERE pn.preferred = 1
  AND pn.voided = 0;

-- $END