-- $BEGIN

-- This Table will only contain Primary keys for only those records that are NEW (i.e. Newly Inserted)

CREATE TEMPORARY TABLE IF NOT EXISTS mamba_etl_incremental_columns_index_new
(
    incremental_table_pkey INT NOT NULL UNIQUE PRIMARY KEY
)
    ENGINE = MEMORY
    CHARSET = UTF8MB4;

-- $END