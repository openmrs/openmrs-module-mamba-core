-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    id                  INT           NOT NULL AUTO_INCREMENT,
    encounter_id        INT           NOT NULL,
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
    voided              TINYINT(1)       NOT NULL,
    voided_by           INT           NULL,
    void_reason         VARCHAR(255)  NULL,
    incremental_record  INT DEFAULT 0 NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_encounter_encounter_id_index
    ON mamba_dim_encounter (encounter_id);

CREATE INDEX mamba_dim_encounter_encounter_type_index
    ON mamba_dim_encounter (encounter_type);

CREATE INDEX mamba_dim_encounter_uuid_index
    ON mamba_dim_encounter (uuid);

CREATE INDEX mamba_dim_encounter_encounter_type_uuid_index
    ON mamba_dim_encounter (encounter_type_uuid);

CREATE INDEX mamba_dim_encounter_patient_id_index
    ON mamba_dim_encounter (patient_id);

CREATE INDEX mamba_dim_encounter_visit_id_index
    ON mamba_dim_encounter (visit_id);

CREATE INDEX mamba_dim_encounter_incremental_record_index
    ON mamba_dim_encounter (incremental_record);

-- $END