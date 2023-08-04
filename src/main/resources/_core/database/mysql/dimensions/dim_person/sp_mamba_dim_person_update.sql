-- $BEGIN
UPDATE mamba_dim_person dp
    INNER JOIN person psn  on psn.person_id = dp.person_id
    INNER JOIN  person_name pn on psn.person_id = pn.person_id
    SET   person_name_short = CONCAT_WS(' ',prefix,given_name,middle_name,family_name),
        person_name_long = CONCAT_WS(' ',prefix,given_name, middle_name,family_name_prefix, family_name,family_name2,family_name_suffix, degree)
WHERE  pn.preferred=1
;
-- $END