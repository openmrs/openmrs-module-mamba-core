-- $BEGIN
INSERT INTO mamba_dim_person_name(person_name_id,
                                  person_id,
                                  preferred,
                                  prefix,
                                  given_name,
                                  middle_name,
                                  family_name_prefix,
                                  family_name,
                                  family_name2,
                                  family_name_suffix,
                                  degree,
                                  date_created,
                                  date_changed,
                                  changed_by,
                                  date_voided,
                                  voided,
                                  voided_by,
                                  void_reason)
SELECT pn.person_name_id,
       pn.person_id,
       pn.preferred,
       pn.prefix,
       pn.given_name,
       pn.middle_name,
       pn.family_name_prefix,
       pn.family_name,
       pn.family_name2,
       pn.family_name_suffix,
       pn.degree,
       pn.date_created,
       pn.date_changed,
       pn.changed_by,
       pn.date_voided,
       pn.voided,
       pn.voided_by,
       pn.void_reason
FROM mamba_source_db.person_name pn;
-- $END



