-- $BEGIN
CREATE TABLE mamba_dim_users
(
    user_id            INT           NOT NULL UNIQUE PRIMARY KEY,
    system_id          VARCHAR(50)   NOT NULL,
    username           VARCHAR(50)   NULL,
    creator            INT           NOT NULL,
    person_id          INT           NOT NULL,
    uuid               CHAR(38)      NOT NULL,
    email              VARCHAR(255)  NULL,
    retired            TINYINT(1)    NULL,
    date_created       DATETIME      NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_retired       DATETIME      NULL,
    retired_by         INT           NULL,
    retire_reason      VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_system_id (system_id),
    INDEX mamba_idx_username (username),
    INDEX mamba_idx_retired (retired),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
