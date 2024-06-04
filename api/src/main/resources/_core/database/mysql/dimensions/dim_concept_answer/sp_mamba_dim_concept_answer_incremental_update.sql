-- $BEGIN
-- Insert only new records
INSERT INTO mamba_dim_concept_answer (concept_answer_id,
                                      concept_id,
                                      answer_concept,
                                      answer_drug,
                                      flag)
SELECT ca.concept_answer_id AS concept_answer_id,
       ca.concept_id        AS concept_id,
       ca.answer_concept    AS answer_concept,
       ca.answer_drug       AS answer_drug,
       1                    flag
FROM mamba_source_db.concept_answer ca
where ca.date_created >= '2023-11-30 00:00:00';

-- $END