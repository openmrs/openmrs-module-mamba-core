-- $BEGIN

CREATE TABLE mamba_dim_conditions
(
    condition_id            INT                  NOT NULL UNIQUE PRIMARY KEY,
    additional_detail       VARCHAR(255)         NULL,
    previous_version        INT                  NULL,
    condition_coded         INT                  NULL,
    condition_non_coded     VARCHAR(255)         NULL,
    condition_coded_name    INT                  NULL,
    clinical_status         VARCHAR(50)          NOT NULL,
    verification_status     VARCHAR(50)          NULL,
    onset_date              DATETIME             NULL,
    date_created            DATETIME             NOT NULL,
    voided                  TINYINT(1) DEFAULT 0 NOT NULL,
    date_voided             DATETIME             NULL,
    void_reason             VARCHAR(255)         NULL,
    uuid                    VARCHAR(38)          NULL,
    creator                 INT                  NOT NULL,
    voided_by               INT                  NULL,
    changed_by              INT                  NULL,
    patient_id              INT                  NOT NULL,
    end_date                DATETIME             NULL,
    date_changed            DATETIME             NULL,
    encounter_id            INT                  NULL,
    form_namespace_and_path VARCHAR(255)         NULL,
    incremental_record      INT DEFAULT 0        NOT NULL,

    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_encounter_type (patient_id),
    INDEX mamba_idx_condition_coded (condition_coded),
    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_condition_id (condition_id),
    INDEX mamba_idx_onset_date (onset_date),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)

)
    CHARSET = UTF8MB4;

-- $END