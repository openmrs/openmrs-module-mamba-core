
-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    obs_question_uuid    CHAR(38) CHARACTER SET UTF8MB4,
    obs_answer_uuid      CHAR(38) CHARACTER SET UTF8MB4,
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
       NULL                   AS obs_answer_uuid,
       NULL                   AS obs_value_coded_uuid
FROM obs o
         INNER JOIN mamba_dim_encounter e
                    ON o.encounter_id = e.external_encounter_id
         INNER JOIN mamba_dim_encounter_type et
                    ON e.external_encounter_type_id = et.external_encounter_type_id
WHERE et.encounter_type_uuid
          IN (SELECT DISTINCT(md.encounter_type_uuid)
              FROM mamba_dim_concept_metadata md); -- only select obs for given encounter types

create index mamba_z_encounter_obs_encounter_id_type_uuid_person_id_index
    on mamba_z_encounter_obs (encounter_id, encounter_type_uuid, person_id);

create index mamba_z_encounter_obs_encounter_type_uuid_index
    on mamba_z_encounter_obs (encounter_type_uuid);

create index mamba_z_encounter_obs_question_concept_id_index
    on mamba_z_encounter_obs (obs_question_concept_id);

create index mamba_z_encounter_obs_value_coded_index
    on mamba_z_encounter_obs (obs_value_coded);

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


-- update obs answer UUIDs
-- UPDATE mamba_z_encounter_obs z
-- INNER JOIN mamba_dim_concept c
-- -- ON z.obs_question_concept_id = c.external_concept_id
-- INNER JOIN mamba_dim_concept_datatype dt
-- ON dt.external_datatype_id = c.external_datatype_id
-- SET z.obs_answer_uuid = (IF(dt.datatype_name = 'Coded',
-- (SELECT c.uuid
-- FROM mamba_dim_concept c
--  where c.external_concept_id = z.obs_value_coded AND z.obs_value_coded IS NOT NULL),
-- c.uuid))
-- WHERE TRUE;

-- $END