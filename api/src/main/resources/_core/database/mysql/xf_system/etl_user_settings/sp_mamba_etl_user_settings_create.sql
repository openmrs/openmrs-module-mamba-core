-- $BEGIN

CREATE TABLE _mamba_etl_user_settings
(
    id                               INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'Primary Key',
    openmrs_database                 VARCHAR(255) NOT NULL DEFAULT 'openmrs',
    etl_database                     VARCHAR(255) NOT NULL DEFAULT 'analysis_db',
    concepts_locale                  VARCHAR(4)   NOT NULL,
    table_partition_number           INT          NOT NULL COMMENT 'Number of columns at which to partition \'many columned\' Tables',
    incremental_mode_switch          TINYINT(1)   NOT NULL COMMENT 'If MambaETL should/not run in Incremental Mode',
    automatic_flattening_mode_switch TINYINT(1)   NOT NULL COMMENT 'If MambaETL should/not automatically flatten ALL encounter types',
    etl_interval_seconds             INT          NOT NULL COMMENT 'ETL Runs every 60 seconds',
    last_etl_schedule_insert_id      INT          NOT NULL DEFAULT 1 COMMENT 'Insert ID of the last ETL that run'

) CHARSET = UTF8MB4;

-- $END