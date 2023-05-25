-- $BEGIN

INSERT INTO mamba_dim_person_name (person_name_id,
                                   person_id,
                                   preferred,
                                   prefix,
                                   given_name,
                                   middle_name,
                                   family_name_prefix,
                                   family_name,
                                   family_name2,
                                   family_name_suffix)
SELECT pn.person_name_id,
       pn.person_id,
       pn.preferred,
       pn.prefix,
       pn.given_name,
       pn.middle_name,
       pn.family_name_prefix,
       pn.family_name,
       pn.family_name2,
       pn.family_name_suffix
FROM person_name pn;

-- $END



