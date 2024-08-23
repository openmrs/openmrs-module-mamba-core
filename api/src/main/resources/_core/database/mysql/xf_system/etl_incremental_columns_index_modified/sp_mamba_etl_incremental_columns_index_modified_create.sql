-- $BEGIN

-- This Table will only contain Primary keys for only those records that have been modified/updated (i.e. Retired, Voided, Changed)

CREATE TEMPORARY TABLE IF NOT EXISTS mamba_etl_incremental_columns_index_modified
(
    incremental_table_pkey INT NOT NULL UNIQUE PRIMARY KEY
)
    ENGINE = MEMORY
    CHARSET = UTF8MB4;

-- $END