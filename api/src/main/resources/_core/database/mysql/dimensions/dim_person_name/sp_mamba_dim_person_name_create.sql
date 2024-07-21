-- $BEGIN

CREATE TABLE mamba_dim_person_name
(
    id                 INT         NOT NULL AUTO_INCREMENT,
    person_name_id     INT         NOT NULL,
    person_id          INT         NOT NULL,
    preferred          TINYINT     NOT NULL,
    prefix             VARCHAR(50) NULL,
    given_name         VARCHAR(50) NULL,
    middle_name        VARCHAR(50) NULL,
    family_name_prefix VARCHAR(50) NULL,
    family_name        VARCHAR(50) NULL,
    family_name2       VARCHAR(50) NULL,
    family_name_suffix VARCHAR(50) NULL,
    degree             VARCHAR(50) NULL,
    voided             TINYINT(1)  NULL,
    date_created       DATETIME    NULL,
    voided_by          INT         NULL,
    date_voided        DATETIME    NULL,
    void_reason        VARCHAR(255) NULL,
    changed_by         INT         NULL,
    date_changed       DATETIME    NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_person_name_person_name_id_index
    ON mamba_dim_person_name (person_name_id);

CREATE INDEX mamba_dim_person_name_person_id_index
    ON mamba_dim_person_name (person_id);

CREATE INDEX mamba_dim_person_name_voided_index
    ON mamba_dim_person_name (voided);

CREATE INDEX mamba_dim_person_name_preferred_index
    ON mamba_dim_person_name (preferred);

CREATE INDEX mamba_dim_person_name_incremental_record_index
    ON mamba_dim_person_name (incremental_record);


-- $END
