-- $BEGIN

CREATE TABLE mamba_etl_user_settings
(
    id                      INT        NOT NULL AUTO_INCREMENT,
    concepts_locale         VARCHAR(4) NOT NULL DEFAULT 'en',
    table_partition_number  INT        NOT NULL DEFAULT 100,
    incremental_mode_switch TINYINT(1) NOT NULL DEFAULT 1,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

-- $END
