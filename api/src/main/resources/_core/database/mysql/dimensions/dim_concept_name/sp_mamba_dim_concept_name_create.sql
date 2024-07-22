-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    id                 INT           NOT NULL AUTO_INCREMENT,
    concept_name_id    INT           NOT NULL,
    concept_id         INT,
    name               VARCHAR(255)  NOT NULL,
    locale             VARCHAR(50)   NOT NULL,
    locale_preferred   TINYINT,
    voided             TINYINT,
    concept_name_type  VARCHAR(255),
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    voided_by          INT           NULL,
    date_voided        DATETIME      NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_concept_name_concept_name_id_index
    ON mamba_dim_concept_name (concept_name_id);

CREATE INDEX mamba_dim_concept_name_concept_id_index
    ON mamba_dim_concept_name (concept_id);

CREATE INDEX mamba_dim_concept_name_concept_name_type_index
    ON mamba_dim_concept_name (concept_name_type);

CREATE INDEX mamba_dim_concept_name_locale_index
    ON mamba_dim_concept_name (locale);

CREATE INDEX mamba_dim_concept_name_locale_preferred_index
    ON mamba_dim_concept_name (locale_preferred);

CREATE INDEX mamba_dim_concept_name_voided_index
    ON mamba_dim_concept_name (voided);

CREATE INDEX mamba_dim_concept_name_incremental_record_index
    ON mamba_dim_concept_name (incremental_record);

-- $END
