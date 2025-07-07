-- $BEGIN

INSERT INTO mamba_dim_encounter_diagnosis (diagnosis_id,
                                           diagnosis_coded,
                                           diagnosis_non_coded,
                                           diagnosis_coded_name,
                                           encounter_id,
                                           patient_id,
                                           condition_id,
                                           certainty,
                                           dx_rank,
                                           uuid,
                                           creator,
                                           date_created,
                                           changed_by,
                                           date_changed,
                                           voided,
                                           voided_by,
                                           date_voided,
                                           void_reason,
                                           form_namespace_and_path)
SELECT
    diagnosis_id,
    diagnosis_coded,
    diagnosis_non_coded,
    diagnosis_coded_name,
    encounter_id,
    patient_id,
    condition_id,
    certainty,
    dx_rank,
    d.uuid,
    creator,
    d.date_created,
    d.changed_by,
    d.date_changed,
    d.voided,
    d.voided_by,
    d.date_voided,
    d.void_reason,
    form_namespace_and_path
FROM mamba_source_db.encounter_diagnosis d
         INNER JOIN mamba_dim_person p
                    ON d.patient_id = p.person_id
-- $END