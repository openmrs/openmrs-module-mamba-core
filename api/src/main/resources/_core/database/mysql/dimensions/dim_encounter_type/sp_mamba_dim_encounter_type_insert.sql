-- $BEGIN

INSERT INTO mamba_dim_encounter_type (encounter_type_id,
                                      uuid,
                                      name,
                                      description,
                                      retired,
                                      date_created,
                                      date_changed,
                                      changed_by,
                                      date_retired,
                                      retired_by,
                                      retire_reason)
SELECT et.encounter_type_id,
       et.uuid,
       et.name,
       et.description,
       et.retired,
       et.date_created,
       et.date_changed,
       et.changed_by,
       et.date_retired,
       et.retired_by,
       et.retire_reason
FROM mamba_source_db.encounter_type et;

-- $END
