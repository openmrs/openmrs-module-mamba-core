-- $BEGIN

-- This table will be used to index the columns that are used to determine if a record is new, changed, retired or voided
-- It will be used to speed up the incremental updates for each incremental Table indentified in the ETL process

CREATE TABLE IF NOT EXISTS mamba_etl_incremental_columns_index_all
(
    id                          INT                                 NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'Primary Key',
    mamba_etl_database_event_id INT                                 NOT NULL,
    incremental_table_pkey      INT                                 NOT NULL,
    database_operation          ENUM ('CREATE', 'UPDATE', 'DELETE') NOT NULL COMMENT 'Operation performed on the Database',

    FOREIGN KEY (`mamba_etl_database_event_id`) REFERENCES `_mamba_etl_database_event` (`id`),

    INDEX mamba_idx_incremental_table_pkey (incremental_table_pkey),
    INDEX mamba_idx_database_operation (database_operation)
)
    CHARSET = UTF8MB4;

-- $END