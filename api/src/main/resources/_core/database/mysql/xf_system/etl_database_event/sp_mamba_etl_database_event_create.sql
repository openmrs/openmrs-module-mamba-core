-- $BEGIN

CREATE TABLE _mamba_etl_database_event
(
    id                     INT                                 NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'Primary Key',
    incremental_table_pkey INT                                 NOT NULL COMMENT 'Primary Key of the record in this event',
    table_name             VARCHAR(100)                        NOT NULL COMMENT 'Name of the Table that emitted this event',
    database_operation     ENUM ('CREATE', 'UPDATE', 'DELETE') NOT NULL COMMENT 'Operation performed on the Database',

    INDEX mamba_idx_database_operation (database_operation),
    INDEX mamba_idx_table_name (table_name),
    INDEX mamba_idx_primary_key_affected (incremental_table_pkey)

) CHARSET = UTF8MB4;

-- $END