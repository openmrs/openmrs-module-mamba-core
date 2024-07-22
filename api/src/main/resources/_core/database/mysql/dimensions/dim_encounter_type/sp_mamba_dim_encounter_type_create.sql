-- $BEGIN

CREATE TABLE mamba_dim_encounter_type
(
    id                 INT           NOT NULL AUTO_INCREMENT,
    encounter_type_id  INT           NOT NULL,
    uuid               CHAR(38)      NOT NULL,
    name               VARCHAR(50)   NOT NULL,
    description        TEXT          NULL,
    retired            TINYINT(1)    NULL,
    date_created       DATETIME      NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_retired       DATETIME      NULL,
    retired_by         INT           NULL,
    retire_reason      VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_encounter_type_encounter_type_id_index
    ON mamba_dim_encounter_type (encounter_type_id);

CREATE INDEX mamba_dim_encounter_type_retired_index
    ON mamba_dim_encounter_type (retired);

CREATE INDEX mamba_dim_encounter_type_uuid_index
    ON mamba_dim_encounter_type (uuid);

CREATE INDEX mamba_dim_encounter_type_name_index
    ON mamba_dim_encounter_type (name);

CREATE INDEX mamba_dim_encounter_type_incremental_record_index
    ON mamba_dim_encounter_type (incremental_record);

-- $END
