-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    concept_name_id    INT           NOT NULL UNIQUE PRIMARY KEY,
    concept_id         INT,
    name               VARCHAR(255)  NOT NULL,
    locale             VARCHAR(50)   NOT NULL,
    locale_preferred   TINYINT,
    concept_name_type  VARCHAR(255),
    voided             TINYINT,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_voided        DATETIME      NULL,
    changed_by         INT           NULL,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_concept_name_type (concept_name_type),
    INDEX mamba_idx_locale (locale),
    INDEX mamba_idx_locale_preferred (locale_preferred),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;
-- $END
