-- $BEGIN

-- Modified Persons
UPDATE mamba_dim_person p
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON p.person_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person psn
    ON p.person_id = psn.person_id
SET p.birthdate           = psn.birthdate,
    p.birthdate_estimated = psn.birthdate_estimated,
    p.dead                = psn.dead,
    p.death_date          = psn.death_date,
    p.deathdate_estimated = psn.deathdate_estimated,
    p.gender              = psn.gender,
    p.uuid                = psn.uuid,
    p.date_created        = psn.date_created,
    p.date_changed        = psn.date_changed,
    p.changed_by          = psn.changed_by,
    p.date_voided         = psn.date_voided,
    p.voided              = psn.voided,
    p.voided_by           = psn.voided_by,
    p.void_reason         = psn.void_reason,
    p.incremental_record  = 1
WHERE im.incremental_table_pkey > 1;

UPDATE mamba_dim_person psn
    INNER JOIN mamba_dim_person_name pn
    on psn.person_id = pn.person_id
SET age               = fn_mamba_age_calculator(psn.birthdate, psn.death_date),
    person_name_short = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name),
    person_name_long  = CONCAT_WS(' ', pn.prefix, pn.given_name, pn.middle_name, pn.family_name_prefix, pn.family_name,
                                  pn.family_name2,
                                  pn.family_name_suffix, pn.degree)
WHERE psn.incremental_record = 1
  AND pn.preferred = 1
  AND pn.voided = 0;

-- $END