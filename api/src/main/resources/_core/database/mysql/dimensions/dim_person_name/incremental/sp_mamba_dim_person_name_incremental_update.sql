-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Modified Encounters
UPDATE mamba_dim_person_name dpn
    INNER JOIN mamba_source_db.person_name pn
    ON dpn.person_name_id = pn.person_name_id
SET dpn.person_name_id     = pn.person_name_id,
    dpn.person_id          = pn.person_id,
    dpn.preferred          = pn.preferred,
    dpn.prefix             = pn.prefix,
    dpn.given_name         = pn.given_name,
    dpn.middle_name        = pn.middle_name,
    dpn.family_name_prefix = pn.family_name_prefix,
    dpn.family_name        = pn.family_name,
    dpn.family_name2       = pn.family_name2,
    dpn.family_name_suffix = pn.family_name_suffix,
    dpn.degree             = pn.degree,
    dpn.date_created       = pn.date_created,
    dpn.date_changed       = pn.date_changed,
    dpn.changed_by         = pn.changed_by,
    dpn.date_voided        = pn.date_voided,
    dpn.voided             = pn.voided,
    dpn.voided_by          = pn.voided_by,
    dpn.void_reason        = pn.void_reason,
    dpn.incremental_record = 1
WHERE pn.date_changed >= @starttime;

-- $END

