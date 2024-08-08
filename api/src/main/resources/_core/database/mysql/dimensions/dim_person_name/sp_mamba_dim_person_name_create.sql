-- $BEGIN

CREATE TABLE mamba_dim_person_name
(
    person_name_id     INT           NOT NULL UNIQUE PRIMARY KEY,
    person_id          INT           NOT NULL,
    preferred          TINYINT       NOT NULL,
    prefix             VARCHAR(50)   NULL,
    given_name         VARCHAR(50)   NULL,
    middle_name        VARCHAR(50)   NULL,
    family_name_prefix VARCHAR(50)   NULL,
    family_name        VARCHAR(50)   NULL,
    family_name2       VARCHAR(50)   NULL,
    family_name_suffix VARCHAR(50)   NULL,
    degree             VARCHAR(50)   NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_voided        DATETIME      NULL,
    changed_by         INT           NULL,
    voided             TINYINT(1)    NOT NULL,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_preferred (preferred),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
