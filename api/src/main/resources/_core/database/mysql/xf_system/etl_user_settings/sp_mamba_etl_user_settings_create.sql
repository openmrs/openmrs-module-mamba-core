-- $BEGIN

CREATE TABLE _mamba_etl_user_settings
(
    id                               INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'Primary Key',
    openmrs_database                 VARCHAR(255) NOT NULL COMMENT 'Name of the OpenMRS (source) database',
    etl_database                     VARCHAR(255) NOT NULL COMMENT 'Name of the ETL (target) database',
    concepts_locale                  CHAR(4)      NOT NULL COMMENT 'Preferred Locale of the Concept names',
    table_partition_number           INT          NOT NULL COMMENT 'Number of columns at which to partition \'many columned\' Tables',
    incremental_mode_switch          TINYINT(1)   NOT NULL COMMENT 'If MambaETL should/not run in Incremental Mode',
    automatic_flattening_mode_switch TINYINT(1)   NOT NULL COMMENT 'If MambaETL should/not automatically flatten ALL encounter types',
    etl_interval_seconds             INT          NOT NULL COMMENT 'ETL Runs every 60 seconds',
    incremental_mode_switch_cascaded TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'This is a computed Incremental Mode (1 or 0) for the ETL that is cascaded down to the implementer scripts',
    last_etl_schedule_insert_id      INT          NOT NULL DEFAULT 1 COMMENT 'Insert ID of the last ETL that ran',
    database_vendor                  VARCHAR(256) NOT NULL COMMENT 'Name of the database vendor e.g. mysql'

) CHARSET = UTF8MB4;

-- $END