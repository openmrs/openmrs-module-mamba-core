-- $BEGIN

INSERT INTO mamba_dim_person_attribute_type (date_created,
                                             description,
                                             name,
                                             person_attribute_type_id,
                                             retired,
                                             searchable,
                                             uuid)
SELECT date_created,
       description,
       name,
       person_attribute_type_id,
       retired,
       searchable,
       uuid
FROM mamba_source_db.person_attribute_type;

-- $END