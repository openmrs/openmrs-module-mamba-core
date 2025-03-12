-- $BEGIN

CREATE TABLE mamba_dim_encounter_diagnosis
(
    diagnosis_id            INT                  NOT NULL PRIMARY KEY ,
    diagnosis_coded         INT                  NULL,
    diagnosis_non_coded     VARCHAR(255)         NULL,
    diagnosis_coded_name    INT                  NULL,
    encounter_id            INT                  NOT NULL,
    patient_id              INT                  NOT NULL,
    condition_id            INT                  NULL,
    certainty               VARCHAR(255)         NOT NULL,
    dx_rank                 INT                  NOT NULL,
    uuid                    char(38)             NOT NULL,
    creator                 INT                  NOT NULL,
    date_created            DATETIME             NOT NULL,
    changed_by              INT                  NULL,
    date_changed            DATETIME             NULL,
    voided                  TINYINT(1) DEFAULT 0 NOT NULL,
    voided_by               INT                  NULL,
    date_voided             DATETIME             NULL,
    void_reason             VARCHAR(255)         NULL,
    form_namespace_and_path VARCHAR(255)         NULL,
    incremental_record      INT DEFAULT 0        NOT NULL,

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_diagnosis_coded (diagnosis_coded),
    INDEX mamba_idx_condition_id (condition_id),
    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_visit_id (diagnosis_id),
    INDEX mamba_idx_date_created (date_created),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END