-- $BEGIN

INSERT INTO mamba_dim_obs_group (
                                 obs_group_concept_id,
                                 obs_group_name,
                                 obs_id)
    SELECT
        DISTINCT
        o.obs_question_concept_id,
        LOWER(LEFT(REPLACE(REPLACE(REPLACE(cn.name,'&',''),' ','_'),'__','_'),12))name,
        obs_id
    FROM mamba_z_encounter_obs o
             INNER JOIN mamba_dim_concept_name cn
                        ON o.obs_question_concept_id = cn.concept_id
    WHERE obs_id in
          (
              SELECT
                  obs_group_id
              FROM
                  (SELECT
                       DISTINCT obs_group_id,
                                COUNT(*) OVER (PARTITION BY person_id,encounter_id,obs_group_id)row_num
                   FROM mamba_z_encounter_obs o
                   WHERE obs_group_id IS NOT NULL) a
              WHERE row_num >1
          )
      AND cn.locale ='en'
      AND cn.locale_preferred = 1
      AND cn.voided = 0
;


-- $END