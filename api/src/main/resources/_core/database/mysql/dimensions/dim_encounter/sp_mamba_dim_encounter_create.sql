-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    id                  INT      NOT NULL AUTO_INCREMENT,
    encounter_id        INT      NOT NULL,
    uuid                CHAR(38) NOT NULL,
    encounter_type      INT      NOT NULL,
    encounter_type_uuid CHAR(38) NULL,
    patient_id          INT      NOT NULL,
    encounter_datetime  DATETIME NOT NULL,
    date_created        DATETIME NOT NULL,
    voided              TINYINT  NOT NULL,
    visit_id            INT      NULL,

    CONSTRAINT encounter_encounter_id_index
        UNIQUE (encounter_id),

    CONSTRAINT encounter_uuid_index
        UNIQUE (uuid),

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

-- $END