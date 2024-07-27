-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_location mdl
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mdl.location_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.location l
    ON mdl.location_id = l.location_id
SET mdl.name               = l.name,
    mdl.description        = l.description,
    mdl.city_village       = l.city_village,
    mdl.state_province     = l.state_province,
    mdl.postal_code        = l.postal_code,
    mdl.country            = l.country,
    mdl.latitude           = l.latitude,
    mdl.longitude          = l.longitude,
    mdl.county_district    = l.county_district,
    mdl.address1           = l.address1,
    mdl.address2           = l.address2,
    mdl.address3           = l.address3,
    mdl.address4           = l.address4,
    mdl.address5           = l.address5,
    mdl.address6           = l.address6,
    mdl.address7           = l.address7,
    mdl.address8           = l.address8,
    mdl.address9           = l.address9,
    mdl.address10          = l.address10,
    mdl.address11          = l.address11,
    mdl.address12          = l.address12,
    mdl.address13          = l.address13,
    mdl.address14          = l.address14,
    mdl.address15          = l.address15,
    mdl.date_created       = l.date_created,
    mdl.changed_by         = l.changed_by,
    mdl.date_changed       = l.date_changed,
    mdl.retired            = l.retired,
    mdl.retired_by         = l.retired_by,
    mdl.date_retired       = l.date_retired,
    mdl.retire_reason      = l.retire_reason,
    mdl.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END