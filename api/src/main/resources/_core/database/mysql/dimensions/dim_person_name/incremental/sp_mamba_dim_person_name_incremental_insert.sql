-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only new records
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
                                  void_reason,
                                  incremental_record)
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
       pn.void_reason,
       1
FROM mamba_source_db.person_name pn
WHERE pn.person_name_id NOT IN (SELECT DISTINCT (person_name_id) FROM mamba_dim_person_name)
  AND pn.date_created >= @starttime;

-- $END