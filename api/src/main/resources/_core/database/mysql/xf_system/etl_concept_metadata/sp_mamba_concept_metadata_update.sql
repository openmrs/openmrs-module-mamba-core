-- $BEGIN

-- Update the Concept datatypes, concept_name and concept_id based on given locale
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid COLLATE utf8mb4_general_ci = c.uuid COLLATE utf8mb4_general_ci
SET md.concept_datatype = c.datatype,
    md.concept_id       = c.concept_id,
    md.concept_name     = c.name
WHERE md.id > 0;

-- All Records' concept_answer_obs field is set to 0 by default
-- what will remain with (concept_answer_obs = 0) after the 2 updates
-- are Question concepts that have other values other than concepts as answers

-- First update: Get All records that are answer concepts (Answers to other question concepts)
-- concept_answer_obs = 1
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer answer
    ON md.concept_id = answer.answer_concept
SET md.concept_answer_obs = 1
WHERE NOT EXISTS (SELECT 1
                  FROM mamba_dim_concept_answer question
                  WHERE question.concept_id = answer.answer_concept);

-- Second update: Get All records that are Both a Question concept and an Answer concept
-- concept_answer_obs = 2
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer answer
    ON md.concept_id = answer.concept_id
SET md.concept_answer_obs = 2
WHERE EXISTS (SELECT 1
              FROM mamba_dim_concept_answer answer2
              WHERE answer2.answer_concept = answer.concept_id);

-- Update row number
SET @row_number = 0;
SET @prev_flat_table_name = NULL;
SET @prev_concept_id = NULL;

UPDATE mamba_concept_metadata md
    INNER JOIN (SELECT flat_table_name,
                       concept_id,
                       id,
                       @row_number := CASE
                                          WHEN @prev_flat_table_name = flat_table_name
                                              AND @prev_concept_id = concept_id
                                              THEN @row_number + 1
                                          ELSE 1
                           END AS num,
                       @prev_flat_table_name := flat_table_name,
                       @prev_concept_id := concept_id
                FROM mamba_concept_metadata
                ORDER BY flat_table_name, concept_id, id) m ON md.id = m.id
SET md.row_num = num
WHERE md.id > 0;

-- $END