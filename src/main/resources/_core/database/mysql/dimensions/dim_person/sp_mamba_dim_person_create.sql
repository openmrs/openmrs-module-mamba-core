-- $BEGIN

CREATE TABLE mamba_dim_person
(
    id                  INT          NOT NULL AUTO_INCREMENT,
    person_id           INT          NOT NULL,
    birthdate           DATE NULL,
    birthdate_estimated TINYINT   NOT NULL,
    dead                TINYINT   NOT NULL,
    death_date          DATETIME     NULL,
    deathdate_estimated TINYINT   NOT NULL,
    gender              VARCHAR(255) NULL,
    date_created        DATETIME     NOT NULL,
    voided              TINYINT   NOT NULL,
    person_name_short   VARCHAR(50) NULL,
    person_name_long    VARCHAR(50) NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_person_person_id_index
    ON mamba_dim_person (person_id);

-- $END
