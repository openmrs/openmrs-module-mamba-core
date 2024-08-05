-- $BEGIN

CREATE TABLE mamba_dim_concept_answer
(
    concept_answer_id  INT           NOT NULL UNIQUE PRIMARY KEY,
    concept_id         INT           NOT NULL,
    answer_concept     INT,
    answer_drug        INT,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_concept_answer (concept_answer_id),
    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END