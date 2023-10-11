-- $BEGIN

INSERT INTO mamba_dim_encounter_type (encounter_type_id,
                                      uuid,
                                      name)
SELECT et.encounter_type_id,
       et.uuid,
       et.name
FROM mamba_source_db.encounter_type et;
-- WHERE et.retired = 0;

-- $END
