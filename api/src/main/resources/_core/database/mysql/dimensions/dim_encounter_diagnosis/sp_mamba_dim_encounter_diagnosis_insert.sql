-- $BEGIN

INSERT INTO mamba_dim_encounter_diagnosis (encounter_id,
                                 uuid,
                                 encounter_type,
                                 encounter_type_uuid,
                                 patient_id,
                                 visit_id,
                                 encounter_datetime,
                                 date_created,
                                 date_changed,
                                 changed_by,
                                 date_voided,
                                 voided,
                                 voided_by,
                                 void_reason)
SELECT e.encounter_id,
       e.uuid,
       e.encounter_type,
       et.uuid,
       e.patient_id,
       e.visit_id,
       e.encounter_datetime,
       e.date_created,
       e.date_changed,
       e.changed_by,
       e.date_voided,
       e.voided,
       e.voided_by,
       e.void_reason
FROM mamba_source_db.encounter_diagnosis e
         INNER JOIN mamba_dim_encounter_type et
                    ON e.encounter_type = et.encounter_type_id
WHERE et.uuid
          IN (SELECT DISTINCT(md.encounter_type_uuid)
              FROM mamba_concept_metadata md);

-- $END