-- $BEGIN

-- This table will be used to index the columns that are used to determine if a record is new, changed, retired or voided
-- It will be used to speed up the incremental updates for each incremental Table indentified in the ETL process

CREATE TABLE IF NOT EXISTS mamba_etl_incremental_columns_index_all
(
    incremental_table_pkey INT        NOT NULL UNIQUE PRIMARY KEY,

    date_created           DATETIME   NOT NULL,
    date_changed           DATETIME   NULL,
    date_retired           DATETIME   NULL,
    date_voided            DATETIME   NULL,

    retired                TINYINT(1) NULL,
    voided                 TINYINT(1) NULL,

    INDEX mamba_idx_date_created (date_created),
    INDEX mamba_idx_date_changed (date_changed),
    INDEX mamba_idx_date_retired (date_retired),
    INDEX mamba_idx_date_voided (date_voided),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_voided (voided)
)
    CHARSET = UTF8MB4;

-- $END