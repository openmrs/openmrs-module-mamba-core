-- $BEGIN

-- Update only Modified Records

-- Update voided Obs (FINAL & AMENDED pair obs are incremental 1 though we shall not consider them in incremental flattening)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_etl_incremental_columns_index_modified im
    ON z.obs_id = im.incremental_table_pkey
    INNER JOIN mamba_source_db.obs o
    ON z.obs_id = o.obs_id
SET z.encounter_id            = o.encounter_id,
    z.person_id               = o.person_id,
    z.order_id                = o.order_id,
    z.obs_datetime            = o.obs_datetime,
    z.location_id             = o.location_id,
    z.obs_group_id            = o.obs_group_id,
    z.obs_question_concept_id = o.concept_id,
    z.obs_value_text          = o.value_text,
    z.obs_value_numeric       = o.value_numeric,
    z.obs_value_coded         = o.value_coded,
    z.obs_value_datetime      = o.value_datetime,
    z.obs_value_complex       = o.value_complex,
    z.obs_value_drug          = o.value_drug,
    z.encounter_type_uuid     = o.encounter_type_uuid,
    z.status                  = o.status,
    z.previous_version        = o.previous_version,
    -- z.row_num            = o.row_num,
    z.date_created            = o.date_created,
    z.voided                  = o.voided,
    z.voided_by               = o.voided_by,
    z.date_voided             = o.date_voided,
    z.void_reason             = o.void_reason,
    z.incremental_record      = 1
WHERE im.incremental_table_pkey > 1;

-- update obs question UUIDs for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_metadata md
    ON z.obs_question_concept_id = md.concept_id
SET z.obs_question_uuid = md.concept_uuid
WHERE z.incremental_record = 1;

-- update obs_value_coded (UUIDs & Concept value names) for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept c
    ON z.obs_value_coded = c.concept_id
SET z.obs_value_text       = c.name,
    z.obs_value_coded_uuid = c.uuid
WHERE z.incremental_record = 1
  AND z.obs_value_coded IS NOT NULL;

-- update column obs_value_boolean (Concept values) for only NEW Obs (not voided)
UPDATE mamba_z_encounter_obs z
SET obs_value_boolean =
        CASE
            WHEN obs_value_text IN ('FALSE', 'No') THEN 0
            WHEN obs_value_text IN ('TRUE', 'Yes') THEN 1
            ELSE NULL
            END
WHERE z.incremental_record = 1
  AND z.obs_value_coded IS NOT NULL
  AND obs_question_concept_id in
      (SELECT DISTINCT concept_id
       FROM mamba_dim_concept c
       WHERE c.datatype = 'Boolean');

-- $END