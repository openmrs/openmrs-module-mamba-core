-- $BEGIN

CREATE TABLE mamba_dim_concept_datatype
(
    concept_datatype_id INT           NOT NULL UNIQUE PRIMARY KEY,
    name                VARCHAR(255)  NOT NULL,
    hl7_abbreviation    VARCHAR(3)    NULL,
    description         VARCHAR(255)  NULL,
    date_created        DATETIME      NOT NULL,
    date_retired        DATETIME      NULL,
    retired             TINYINT(1)    NULL,
    retire_reason       VARCHAR(255)  NULL,
    retired_by          INT           NULL,
    incremental_record  INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_name (name),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END