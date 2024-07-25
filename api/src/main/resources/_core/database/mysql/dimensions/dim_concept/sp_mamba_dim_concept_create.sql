-- $BEGIN

CREATE TABLE mamba_dim_concept
(
    concept_id         INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid               CHAR(38)      NOT NULL,
    datatype_id        INT           NOT NULL, -- make it a FK
    datatype           VARCHAR(100)  NULL,
    name               VARCHAR(256)  NULL,
    retired            TINYINT(1)    NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_retired       DATETIME      NULL,
    retired_by         INT           NULL,
    retire_reason      VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_datatype_id (datatype_id),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_incremental_record (incremental_record),
    INDEX mamba_idx_date_created (date_created)
)
    CHARSET = UTF8MB4;

-- $END
