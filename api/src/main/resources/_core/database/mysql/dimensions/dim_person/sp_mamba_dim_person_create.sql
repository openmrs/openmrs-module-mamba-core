-- $BEGIN

CREATE TABLE mamba_dim_person
(
    person_id           INT           NOT NULL UNIQUE PRIMARY KEY,
    birthdate           DATE          NULL,
    birthdate_estimated TINYINT(1)    NOT NULL,
    age                 INT           NULL,
    dead                TINYINT(1)    NOT NULL,
    death_date          DATETIME      NULL,
    deathdate_estimated TINYINT       NOT NULL,
    gender              VARCHAR(50)   NULL,
    person_name_short   VARCHAR(255)  NULL,
    person_name_long    TEXT          NULL,
    uuid                CHAR(38)      NOT NULL,
    date_created        DATETIME      NOT NULL,
    date_changed        DATETIME      NULL,
    changed_by          INT           NULL,
    date_voided         DATETIME      NULL,
    voided              TINYINT(1)    NOT NULL,
    voided_by           INT           NULL,
    void_reason         VARCHAR(255)  NULL,
    incremental_record  INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_incremental_record (incremental_record)

) CHARSET = UTF8MB4;

-- $END
