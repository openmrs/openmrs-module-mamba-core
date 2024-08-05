-- $BEGIN

CREATE TABLE mamba_dim_concept
(
    concept_id             INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid                   CHAR(38)      NOT NULL,
    datatype_id            INT           NOT NULL, -- make it a FK
    datatype               VARCHAR(100)  NULL,
    name                   VARCHAR(256)  NULL,
    auto_table_column_name VARCHAR(60)   NULL,
    date_created           DATETIME      NOT NULL,
    date_changed           DATETIME      NULL,
    date_retired           DATETIME      NULL,
    retired                TINYINT(1)    NULL,
    retire_reason          VARCHAR(255)  NULL,
    retired_by             INT           NULL,
    changed_by             INT           NULL,
    incremental_record     INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_datatype_id (datatype_id),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_date_created (date_created),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END