-- $BEGIN
DROP PROCEDURE IF EXISTS sp_mamba_z_encounter_obs_insert;

DELIMITER //

CREATE TEMPORARY TABLE mamba_temp_obs_group_ids
(
    obs_group_id INT NOT NULL,
    row_num      INT NOT NULL,

    INDEX mamba_idx_obs_group_id (obs_group_id),
    INDEX mamba_idx_visit_id (row_num)
)
    CHARSET = UTF8MB4;

INSERT INTO mamba_temp_obs_group_ids
SELECT obs_group_id,
       COUNT(*) AS row_num
FROM mamba_z_encounter_obs o
WHERE obs_group_id IS NOT NULL
GROUP BY obs_group_id, person_id, encounter_id;

INSERT INTO mamba_obs_group (obs_group_concept_id,
                             obs_group_concept_name,
                             obs_id)
SELECT DISTINCT o.obs_question_concept_id,
                LEFT(c.auto_table_column_name, 12) AS name,
                o.obs_id
FROM mamba_temp_obs_group_ids t
         INNER JOIN mamba_z_encounter_obs o
                    ON t.obs_group_id = o.obs_group_id
         INNER JOIN mamba_dim_concept c
                    ON o.obs_question_concept_id = c.concept_id
WHERE t.row_num > 1;

DROP TEMPORARY TABLE mamba_temp_obs_group_ids;

-- $END