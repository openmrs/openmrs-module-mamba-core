-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    obs_question_uuid    CHAR(38) CHARACTER SET UTF8MB4,
    obs_value_coded_uuid CHAR(38) CHARACTER SET UTF8MB4,
    encounter_type_uuid  CHAR(38) CHARACTER SET UTF8MB4
)
SELECT o.encounter_id         AS encounter_id,
       o.person_id            AS person_id,
       o.obs_datetime         AS obs_datetime,
       o.concept_id           AS obs_question_concept_id,
       o.value_text           AS obs_value_text,
       o.value_numeric        AS obs_value_numeric,
       o.value_coded          AS obs_value_coded,
       o.value_datetime       AS obs_value_datetime,
       o.value_complex        AS obs_value_complex,
       o.value_drug           AS obs_value_drug,
       et.encounter_type_uuid AS encounter_type_uuid,
       NULL                   AS obs_question_uuid,
       NULL                   AS obs_value_coded_uuid
FROM obs o
         INNER JOIN mamba_dim_encounter e
                    ON o.encounter_id = e.external_encounter_id
         INNER JOIN mamba_dim_encounter_type et
                    ON e.external_encounter_type_id = et.external_encounter_type_id
WHERE et.encounter_type_uuid
          IN (SELECT DISTINCT(md.encounter_type_uuid)
              FROM mamba_dim_concept_metadata md);

CREATE INDEX mamba_z_encounter_obs_encounter_id_type_uuid_person_id_index
    ON mamba_z_encounter_obs (encounter_id, encounter_type_uuid, person_id);

CREATE INDEX mamba_z_encounter_obs_encounter_id_person_id_index
    ON mamba_z_encounter_obs (encounter_id, person_id);

CREATE INDEX mamba_z_encounter_obs_encounter_id_index
    ON mamba_z_encounter_obs (encounter_id);

CREATE INDEX mamba_z_encounter_obs_encounter_type_uuid_index
    ON mamba_z_encounter_obs (encounter_type_uuid);

CREATE INDEX mamba_z_encounter_obs_question_concept_id_index
    ON mamba_z_encounter_obs (obs_question_concept_id);

CREATE INDEX mamba_z_encounter_obs_value_coded_index
    ON mamba_z_encounter_obs (obs_value_coded);

CREATE INDEX mamba_z_encounter_obs_value_coded_uuid_index
    ON mamba_z_encounter_obs (obs_value_coded_uuid);

CREATE INDEX mamba_z_encounter_obs_question_uuid_index
    ON mamba_z_encounter_obs (obs_question_uuid);

-- update obs question UUIDs
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept c
    ON z.obs_question_concept_id = c.external_concept_id
SET z.obs_question_uuid = c.uuid
WHERE TRUE;

-- update obs_value_coded (UUIDs & values)
UPDATE mamba_z_encounter_obs z
    INNER JOIN mamba_dim_concept_name cn
    ON z.obs_value_coded = cn.external_concept_id
    INNER JOIN mamba_dim_concept c
    ON z.obs_value_coded = c.external_concept_id
SET z.obs_value_text       = cn.concept_name,
    z.obs_value_coded_uuid = c.uuid
WHERE z.obs_value_coded IS NOT NULL;

-- $END