-- $BEGIN

INSERT INTO mamba_dim_person
    (
        person_id,
        birthdate,
        birthdate_estimated,
        age,
        dead,
        death_date,
        deathdate_estimated,
        gender,
        date_created,
        uuid,
        voided
    )

    SELECT psn.person_id,
           psn.birthdate,
           psn.birthdate_estimated,
           fn_mamba_age_calculator(birthdate,death_date) AS age,
           psn.dead,
           psn.death_date,
           psn.deathdate_estimated,
           psn.gender,
           psn.date_created,
           psn.uuid,
           psn.voided
    FROM person psn;

-- $END