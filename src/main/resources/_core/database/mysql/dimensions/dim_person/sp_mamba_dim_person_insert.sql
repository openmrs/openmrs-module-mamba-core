-- $BEGIN

INSERT INTO mamba_dim_person (person_id,
                              birthdate,
                              birthdate_estimated,
                              dead,
                              death_date,
                              deathdate_estimated,
                              gender,
                              date_created,
                              uuid,
                              voided)
SELECT person_id,
       birthdate,
       birthdate_estimated,
       dead,
       death_date,
       deathdate_estimated,
       gender,
       date_created,
       uuid,
       voided
FROM person;

-- $END