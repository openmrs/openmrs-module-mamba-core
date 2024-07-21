-- $BEGIN

CREATE TABLE mamba_dim_patient_identifier_type
(
    id                         INT         NOT NULL AUTO_INCREMENT,
    patient_identifier_type_id INT         NOT NULL,
    name                       VARCHAR(50) NOT NULL,
    description                TEXT        NULL,
    uuid                       CHAR(38)    NOT NULL,
    date_created               DATETIME    NULL,
    date_changed               DATETIME    NULL,
    changed_by                 INT         NULL,
    retired                    TINYINT(1)  NULL,
    retired_by                 INT         NULL,
    retire_reason              VARCHAR(255) NULL,
    incremental_record         INT DEFAULT 0 NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_patient_identifier_type_id_index
    ON mamba_dim_patient_identifier_type (patient_identifier_type_id);

CREATE INDEX mamba_dim_patient_identifier_type_name_index
    ON mamba_dim_patient_identifier_type (name);

CREATE INDEX mamba_dim_patient_identifier_type_uuid_index
    ON mamba_dim_patient_identifier_type (uuid);

CREATE INDEX mamba_dim_patient_identifier_type_incremental_record_index
    ON mamba_dim_patient_identifier_type (incremental_record);

-- $END
