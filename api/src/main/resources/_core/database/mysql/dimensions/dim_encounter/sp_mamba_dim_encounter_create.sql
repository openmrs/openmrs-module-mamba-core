-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    encounter_id        INT           NOT NULL UNIQUE PRIMARY KEY,
    uuid                CHAR(38)      NOT NULL,
    encounter_type      INT           NOT NULL,
    encounter_type_uuid CHAR(38)      NULL,
    patient_id          INT           NOT NULL,
    visit_id            INT           NULL,
    encounter_datetime  DATETIME      NOT NULL,
    date_created        DATETIME      NOT NULL,
    date_changed        DATETIME      NULL,
    changed_by          INT           NULL,
    date_voided         DATETIME      NULL,
    voided              TINYINT(1)    NOT NULL,
    voided_by           INT           NULL,
    void_reason         VARCHAR(255)  NULL,
    incremental_record  INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_encounter_type (encounter_type),
    INDEX mamba_idx_encounter_type_uuid (encounter_type_uuid),
    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_visit_id (visit_id),
    INDEX mamba_idx_encounter_datetime (encounter_datetime),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END