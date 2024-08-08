-- $BEGIN

-- Update only Modified Records
UPDATE mamba_dim_person_address mpa
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mpa.person_address_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.person_address pa
    ON mpa.person_address_id = pa.person_address_id
SET mpa.person_id          = pa.person_id,
    mpa.preferred          = pa.preferred,
    mpa.address1           = pa.address1,
    mpa.address2           = pa.address2,
    mpa.address3           = pa.address3,
    mpa.address4           = pa.address4,
    mpa.address5           = pa.address5,
    mpa.address6           = pa.address6,
    mpa.address7           = pa.address7,
    mpa.address8           = pa.address8,
    mpa.address9           = pa.address9,
    mpa.address10          = pa.address10,
    mpa.address11          = pa.address11,
    mpa.address12          = pa.address12,
    mpa.address13          = pa.address13,
    mpa.address14          = pa.address14,
    mpa.address15          = pa.address15,
    mpa.city_village       = pa.city_village,
    mpa.county_district    = pa.county_district,
    mpa.state_province     = pa.state_province,
    mpa.postal_code        = pa.postal_code,
    mpa.country            = pa.country,
    mpa.latitude           = pa.latitude,
    mpa.longitude          = pa.longitude,
    mpa.date_created       = pa.date_created,
    mpa.date_changed       = pa.date_changed,
    mpa.date_voided        = pa.date_voided,
    mpa.changed_by         = pa.changed_by,
    mpa.voided             = pa.voided,
    mpa.voided_by          = pa.voided_by,
    mpa.void_reason        = pa.void_reason,
    mpa.incremental_record = 1
WHERE im.incremental_table_pkey > 1;

-- $END