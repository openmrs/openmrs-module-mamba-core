-- $BEGIN

-- Insert only new records
INSERT INTO mamba_dim_concept_answer (concept_answer_id,
                                      concept_id,
                                      answer_concept,
                                      answer_drug,
                                      incremental_record)
SELECT ca.concept_answer_id AS concept_answer_id,
       ca.concept_id        AS concept_id,
       ca.answer_concept    AS answer_concept,
       ca.answer_drug       AS answer_drug,
       1
FROM mamba_source_db.concept_answer ca
         INNER JOIN mamba_etl_incremental_columns_index_new ic
                    ON ca.concept_answer_id = ic.incremental_table_pkey;

-- $END