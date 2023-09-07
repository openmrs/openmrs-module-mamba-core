-- $BEGIN

CREATE TABLE [analysis_db].mamba_dim_person_name
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
    voided             TINYINT(1)  NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_person_name_person_name_id_index
    ON [analysis_db].mamba_dim_person_name (person_name_id);

CREATE INDEX mamba_dim_person_name_person_id_index
    ON [analysis_db].mamba_dim_person_name (person_id);

CREATE INDEX mamba_dim_person_name_voided_index
    ON [analysis_db].mamba_dim_person_name (voided);

CREATE INDEX mamba_dim_person_name_preferred_index
    ON [analysis_db].mamba_dim_person_name (preferred);

-- $END
