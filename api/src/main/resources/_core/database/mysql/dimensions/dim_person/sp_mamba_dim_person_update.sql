-- $BEGIN

UPDATE mamba_dim_person psn
    INNER JOIN mamba_dim_person_name pn
    on psn.person_id = pn.person_id
SET age               = fn_mamba_age_calculator(psn.birthdate, psn.death_date),
    person_name_short = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name),
    person_name_long  = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name_prefix, pn.family_name,
                                  pn.family_name2,
                                  pn.family_name_suffix, pn.degree)
WHERE pn.preferred = 1
  AND pn.voided = 0;

-- $END