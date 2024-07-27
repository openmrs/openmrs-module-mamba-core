-- $BEGIN

CREATE TABLE mamba_dim_patient_identifier_type
(
    patient_identifier_type_id INT         NOT NULL UNIQUE PRIMARY KEY,
    name                       VARCHAR(50) NOT NULL,
    description                TEXT        NULL,
    uuid                       CHAR(38)    NOT NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_retired       DATETIME      NULL,
    retired            TINYINT(1)    NULL,
    retire_reason      VARCHAR(255)  NULL,
    retired_by         INT           NULL,
    changed_by         INT           NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_uuid (name),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END