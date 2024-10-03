-- $BEGIN

-- Update the Concept datatypes, concept_name and concept_id based on given locale
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid = c.uuid
SET md.concept_datatype = c.datatype,
    md.concept_id       = c.concept_id,
    md.concept_name     = c.name
WHERE md.id > 0;

-- Get All records that Both a Question concept and an Answer concept
-- SET concept_answer_obs = 2
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer ca
    ON md.concept_id = ca.concept_id
SET md.concept_answer_obs = 2
WHERE EXISTS (SELECT 1
              FROM mamba_dim_concept_answer ca2
              WHERE ca2.answer_concept = ca.concept_id);

-- Get All records that are answer concepts
-- SET concept_answer_obs = 1
-- UPDATE mamba_concept_metadata md
--     INNER JOIN mamba_dim_concept_answer ca
--     ON ca.answer_concept = md.concept_id
-- SET md.concept_answer_obs = 1
-- WHERE md.concept_answer_obs <> 2;

UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer ca
    ON ca.answer_concept = md.concept_id
SET md.concept_answer_obs = 1
WHERE md.concept_id NOT IN (SELECT ca2.concept_id
                            FROM mamba_dim_concept_answer ca2
                            WHERE EXISTS (SELECT 1
                                          FROM mamba_dim_concept_answer ca3
                                          WHERE ca3.answer_concept = ca2.concept_id));

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