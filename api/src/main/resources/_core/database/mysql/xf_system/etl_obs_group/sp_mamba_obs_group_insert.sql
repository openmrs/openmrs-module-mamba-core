-- $BEGIN

INSERT INTO mamba_obs_group (obs_group_concept_id,
                             obs_group_concept_name,
                             obs_id)
SELECT DISTINCT o.obs_question_concept_id,
                LEFT(c.auto_table_column_name, 12) AS name,
                obs_id
FROM mamba_z_encounter_obs o
         INNER JOIN mamba_dim_concept c
                    ON o.obs_question_concept_id = c.concept_id
WHERE obs_id in
      (SELECT obs_group_id
       FROM (SELECT DISTINCT obs_group_id,
                             (SELECT COUNT(*)
                              FROM mamba_z_encounter_obs o2
                              WHERE o2.obs_group_id = o.obs_group_id
                                AND o2.person_id = o.person_id
                                AND o2.encounter_id = o.encounter_id) AS row_num
             FROM mamba_z_encounter_obs o
             WHERE obs_group_id IS NOT NULL) a
       WHERE row_num > 1);

-- $END