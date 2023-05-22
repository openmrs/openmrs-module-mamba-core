-- $BEGIN

INSERT INTO mamba_dim_encounter (external_encounter_id,
                                 external_encounter_type_id,
                                 patient_id,
                                 encounter_datetime,
                                 date_created,
                                 voided,
                                 visit_id)
SELECT e.encounter_id   AS external_encounter_id,
       e.encounter_type AS external_encounter_type_id,
       e.patient_id,
       e.encounter_datetime,
       e.date_created,
       e.voided,
       e.visit_id
FROM encounter e;

-- $END
