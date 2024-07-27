-- $BEGIN

CREATE TABLE mamba_dim_encounter_type
(
    encounter_type_id  INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid               CHAR(38)      NOT NULL,
    name               VARCHAR(50)   NOT NULL,
    description        TEXT          NULL,
    retired            TINYINT(1)    NULL,
    date_created       DATETIME      NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_retired       DATETIME      NULL,
    retired_by         INT           NULL,
    retire_reason      VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_name (name),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
