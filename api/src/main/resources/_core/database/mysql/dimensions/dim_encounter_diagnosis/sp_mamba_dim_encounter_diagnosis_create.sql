-- $BEGIN

CREATE TABLE mamba_dim_encounter_diagnosis
(
    diagnosis_id            INT                  NOT NULL UNIQUE PRIMARY KEY,
    diagnosis_coded         int                  null,
    diagnosis_non_coded     varchar(255)         null,
    diagnosis_coded_name    int                  null,
    encounter_id            int                  not null,
    patient_id              int                  not null,
    condition_id            int                  null,
    certainty               varchar(255)         not null,
    dx_rank                 int                  not null,
    uuid                    char(38)             not null,
    creator                 int                  not null,
    date_created            datetime             not null,
    changed_by              int                  null,
    date_changed            datetime             null,
    voided                  tinyint(1) default 0 not null,
    voided_by               int                  null,
    date_voided             datetime             null,
    void_reason             varchar(255)         null,
    form_namespace_and_path varchar(255)         null,
    incremental_record      INT        DEFAULT 0 NOT NULL,

    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_patient_id (patient_id),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END