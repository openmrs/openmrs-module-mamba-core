-- $BEGIN

INSERT INTO mamba_dim_person_address (person_address_id,
                                      person_id,
                                      preferred,
                                      address1,
                                      address2,
                                      city_village,
                                      county_district,
                                      state_province,
                                      postal_code,
                                      country,
                                      latitude,
                                      longitude)
SELECT pa.person_address_id,
       pa.person_id,
       pa.preferred,
       pa.address1,
       pa.address2,
       pa.city_village,
       pa.county_district,
       pa.state_province,
       pa.postal_code,
       pa.country,
       pa.latitude,
       pa.longitude
FROM person_address pa;

-- $END