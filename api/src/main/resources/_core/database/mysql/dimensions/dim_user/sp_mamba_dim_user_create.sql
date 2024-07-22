-- $BEGIN
CREATE TABLE mamba_dim_users
(
    id                 INT           NOT NULL AUTO_INCREMENT,
    user_id            INT           NOT NULL,
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

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_users_user_id_index
    ON mamba_dim_users (user_id);

CREATE INDEX mamba_dim_users_incremental_record_index
    ON mamba_dim_users (incremental_record);

-- $END