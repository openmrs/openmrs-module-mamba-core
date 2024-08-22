-- $BEGIN
-- Step 1: Create a temporary table and insert the data
CREATE TEMPORARY TABLE mamba_temp_obs_value_code
(
    person_id               INT          NOT NULL,
    encounter_id            INT          NOT NULL,
    obs_datetime            DATE         NOT NULL,
    obs_question_concept_id INT          NOT NULL,
    concept_name            VARCHAR(255) NOT NULL,
    distinct_coded_count    INT          NOT NULL,

    INDEX mamba_idx_obs_datetime (obs_datetime),
    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_concept_name (concept_name),
    INDEX mamba_idx_obs_question_concept_id (obs_question_concept_id)
)
    CHARSET = UTF8MB4;

INSERT INTO mamba_temp_obs_value_code
SELECT DISTINCT
    o.person_id,
    o.encounter_id,
    DATE(o.obs_datetime) AS obs_datetime,
    o.obs_question_concept_id,
    cn.name,
    COUNT(DISTINCT o.obs_value_coded) AS distinct_coded_count
FROM
    mamba_dim_concept_name cn
    INNER JOIN
    mamba_z_encounter_obs o ON o.obs_question_concept_id = cn.concept_id
WHERE
    cn.voided = 0
  AND cn.locale_preferred = 1
  AND cn.locale = 'en'
GROUP BY
    o.person_id, o.encounter_id, DATE(o.obs_datetime), o.obs_question_concept_id, cn.name
HAVING
    COUNT(DISTINCT o.obs_value_coded) > 1;

-- Step 2: Insert the actual data into the final table using the temporary table
INSERT INTO mamba_multiselect_questions (obs_id,
                                         person_id,
                                         encounter_id,
                                         obs_datetime,
                                         obs_question_concept_id,
                                         concept_name,
                                         obs_value_coded)
SELECT
    o.obs_id,
    o.person_id,
    o.encounter_id,
    DATE(o.obs_datetime) AS obs_datetime,
    o.obs_question_concept_id,
    cn.name AS concept_name,
    o.obs_value_coded
FROM
    mamba_z_encounter_obs o
INNER JOIN
    mamba_dim_concept_name cn ON o.obs_question_concept_id = cn.concept_id
INNER JOIN
    temp_distinct_counts tdc ON tdc.obs_question_concept_id = o.obs_question_concept_id
    AND tdc.name = cn.name
    AND tdc.person_id = o.person_id
    AND tdc.encounter_id = o.encounter_id
    AND tdc.obs_datetime = DATE(o.obs_datetime);

-- Step 3: Drop the temporary table to clean up
DROP TEMPORARY TABLE mamba_temp_obs_value_code;

-- $END