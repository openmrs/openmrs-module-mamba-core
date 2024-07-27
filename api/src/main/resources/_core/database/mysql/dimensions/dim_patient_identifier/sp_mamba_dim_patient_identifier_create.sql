-- $BEGIN

CREATE TABLE mamba_dim_patient_identifier
(
    patient_identifier_id INT           NOT NULL UNIQUE PRIMARY KEY,
    patient_id            INT           NOT NULL,
    identifier            VARCHAR(50)   NOT NULL,
    identifier_type       INT           NOT NULL,
    preferred             TINYINT       NOT NULL,
    location_id           INT           NULL,
    patient_program_id    INT           NULL,
    uuid                  CHAR(38)      NOT NULL,
    date_created          DATETIME      NOT NULL,
    date_changed          DATETIME      NULL,
    date_voided           DATETIME      NULL,
    changed_by            INT           NULL,
    voided                TINYINT,
    voided_by             INT           NULL,
    void_reason           VARCHAR(255)  NULL,
    incremental_record    INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_identifier (identifier),
    INDEX mamba_idx_identifier_type (identifier_type),
    INDEX mamba_idx_preferred (preferred),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END