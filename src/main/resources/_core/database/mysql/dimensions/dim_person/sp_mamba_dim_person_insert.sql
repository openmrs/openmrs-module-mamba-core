-- $BEGIN

INSERT INTO mamba_dim_person (person_id,
                              birthdate,
                              birthdate_estimated,
                              dead,
                              death_date,
                              deathdate_estimated,
                              gender,
                              date_created,
                              voided)
SELECT psn.person_id,
       psn.birthdate,
       psn.birthdate_estimated,
       psn.dead,
       psn.death_date,
       psn.deathdate_estimated,
       psn.gender,
       psn.date_created,
       psn.voided
FROM person psn;

-- $END