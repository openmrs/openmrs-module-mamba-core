-- $BEGIN

CREATE TABLE mamba_dim_concept_answer
(
    id                 INT           NOT NULL AUTO_INCREMENT,
    concept_answer_id  INT           NOT NULL,
    concept_id         INT           NOT NULL,
    answer_concept     INT,
    answer_drug        INT,
    incremental_record INT DEFAULT 0 NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_concept_answer_concept_answer_id_index
    ON mamba_dim_concept_answer (concept_answer_id);

CREATE INDEX mamba_dim_concept_answer_concept_id_index
    ON mamba_dim_concept_answer (concept_id);

CREATE INDEX mamba_dim_concept_answer_incremental_record_index
    ON mamba_dim_concept_answer (incremental_record);

-- $END