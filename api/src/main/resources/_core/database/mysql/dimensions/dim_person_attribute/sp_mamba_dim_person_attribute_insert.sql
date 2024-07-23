-- $BEGIN

INSERT INTO mamba_dim_person_attribute (date_created,
                                          person_attribute_id,
                                          person_attribute_type_id,
                                          person_id,
                                          uuid,
                                          value,
                                          voided)
SELECT date_created,
       person_attribute_id,
       person_attribute_type_id,
       person_id,
       uuid,
       value,
       voided
FROM mamba_source_db.person_attribute;

-- $END