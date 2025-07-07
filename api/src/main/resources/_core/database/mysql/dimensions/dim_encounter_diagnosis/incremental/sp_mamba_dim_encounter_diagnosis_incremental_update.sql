-- Modified Encounters
UPDATE mamba_dim_encounter_diagnosis mded 
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON mded.encounter_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.encounter_diagnosis enc
    ON mded.encounter_id = enc.encounter_id
    INNER JOIN mamba_dim_person p
    ON mded.patient_id = p.person_id
SET mded.encounter_id        = enc.encounter_id,
    mded.uuid                = enc.uuid,
    mded.patient_id          = enc.patient_id,
    mded.diagnosis_coded     = enc.diagnosis_coded,
    mded.diagnosis_non_coded = enc.diagnosis_non_coded,
    mded.diagnosis_coded_name = enc.diagnosis_coded_name,
    mded.encounter_datetime  = enc.encounter_datetime,
    mded.date_created        = enc.date_created,
    mded.date_changed        = enc.date_changed,
    mded.changed_by          = enc.changed_by,
    mded.date_voided         = enc.date_voided,
    mded.voided              = enc.voided,
    mded.voided_by           = enc.voided_by,
    mded.void_reason         = enc.void_reason,
    mded.incremental_record  = 1
WHERE im.incremental_table_pkey > 1;

-- $END