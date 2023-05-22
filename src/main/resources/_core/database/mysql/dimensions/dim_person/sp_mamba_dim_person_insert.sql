-- $BEGIN

INSERT INTO mamba_dim_person (external_person_id,
                              birthdate,
                              gender,
                              date_created,
                              voided)
SELECT psn.person_id AS external_person_id,
       psn.birthdate AS birthdate,
       psn.gender    AS gender,
       psn.date_created,
       psn.voided
FROM person psn;

-- $END