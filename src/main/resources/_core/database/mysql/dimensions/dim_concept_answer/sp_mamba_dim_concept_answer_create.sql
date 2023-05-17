-- $BEGIN

CREATE TABLE mamba_dim_concept_answer
(
    concept_answer_id INT NOT NULL AUTO_INCREMENT,
    concept_id        INT,
    answer_concept    INT,
    answer_drug       INT,
    PRIMARY KEY (concept_answer_id)
);

create index mamba_dim_concept_answer_concept_id_index
    on mamba_dim_concept_answer (concept_id);

create index mamba_dim_concept_answer_concept_index
    on mamba_dim_concept_answer (answer_concept);

-- $END