-- $BEGIN

-- Update the Concept datatypes, concept_name and concept_id based on given locale
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept c
    ON md.concept_uuid = c.uuid
SET md.concept_datatype = c.datatype,
    md.concept_id       = c.concept_id,
    md.concept_name     = c.name
WHERE md.id > 0;

-- Update to True if this field is an obs answer to an obs Question
UPDATE mamba_concept_metadata md
    INNER JOIN mamba_dim_concept_answer ca
    ON md.concept_id = ca.answer_concept
SET md.concept_answer_obs = 1
WHERE md.id > 0
  AND md.concept_id IN (SELECT DISTINCT ca.concept_id
                        FROM mamba_dim_concept_answer ca);

-- Update to for multiple selects/dropdowns/options this field is an obs answer to an obs Question
-- TODO: check this implementation here
UPDATE mamba_concept_metadata md
SET md.concept_answer_obs = 1
WHERE md.id > 0
  and concept_datatype = 'N/A';

-- Update row number
UPDATE mamba_concept_metadata md
    INNER JOIN (SELECT flat_table_name,
                       concept_id,
                       id,
                       @row_number := CASE
                                          WHEN @prev_flat_table_name = flat_table_name AND @prev_concept_id = concept_id
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
