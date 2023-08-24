-- $BEGIN

CREATE TABLE mamba_dim_person
(
    id                  INT          NOT NULL AUTO_INCREMENT,
    person_id           INT          NOT NULL,
    birthdate           DATE         NULL,
    birthdate_estimated TINYINT      NOT NULL,
    age                 INT          NULL,
    dead                TINYINT      NOT NULL,
    death_date          DATETIME     NULL,
    deathdate_estimated TINYINT      NOT NULL,
    gender              VARCHAR(255) NULL,
    date_created        DATETIME     NOT NULL,
    person_name_short   VARCHAR(255) NULL,
    person_name_long    TEXT         NULL,
    uuid                CHAR(38)     NOT NULL,
    voided              TINYINT      NOT NULL,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_person_person_id_index
    ON mamba_dim_person (person_id);

CREATE INDEX mamba_dim_person_uuid_index
    ON mamba_dim_person (uuid);

-- $END
