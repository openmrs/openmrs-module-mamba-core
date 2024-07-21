-- $BEGIN

SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

UPDATE mamba_dim_location mdl
INNER JOIN mamba_source_db.location l
ON l.location_id = mdl.location_id
SET
    mdl.name = l.name ,
    mdl.description = l.description,
    mdl.city_village = l.city_village,
    mdl.state_province = l.state_province,
    mdl.postal_code = l.postal_code,
    mdl.country = l.country,
    mdl.latitude = l.latitude,
    mdl.longitude = l.longitude,
    mdl.county_district = l.county_district,
    mdl.date_created = l.date_created,
    mdl.changed_by = l.changed_by,
    mdl.date_changed = l.date_changed,
    mdl.retired = l.retired,
    mdl.retired_by = l.retired_by,
    mdl.date_retired = l.date_retired,
    mdl.retire_reason = l.retire_reason,
    mdl.incremental_record = 1
WHERE l.date_changed >= @starttime;

-- $END