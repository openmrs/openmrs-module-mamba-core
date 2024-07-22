-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    id                      INT           NOT NULL AUTO_INCREMENT,
    obs_id                  INT           NOT NULL,
    encounter_id            INT           NULL,
    person_id               INT           NOT NULL,
    order_id                INT           NULL,
    encounter_datetime      DATETIME      NOT NULL,
    obs_datetime            DATETIME      NOT NULL,
    location_id             INT           NULL,
    obs_group_id            INT           NULL,
    obs_question_concept_id INT DEFAULT 0 NOT NULL,
    obs_value_text          TEXT          NULL,
    obs_value_numeric       DOUBLE        NULL,
    obs_value_boolean       BOOLEAN       NULL,
    obs_value_coded         INT           NULL,
    obs_value_datetime      DATETIME      NULL,
    obs_value_complex       VARCHAR(1000) NULL,
    obs_value_drug          INT           NULL,
    obs_question_uuid       CHAR(38),
    obs_answer_uuid         CHAR(38),
    obs_value_coded_uuid    CHAR(38),
    encounter_type_uuid     CHAR(38),
    status                  VARCHAR(16)   NOT NULL,
    previous_version        INT           NULL,
    row_num                 INT           NULL,
    date_created            DATETIME      NOT NULL,
    date_voided             DATETIME      NULL,
    voided                  TINYINT(1)    NOT NULL,
    voided_by               INT           NULL,
    void_reason             VARCHAR(255)  NULL,
    incremental_record      INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_z_encounter_obs_encounter_id_type_uuid_person_id_index
    ON mamba_z_encounter_obs (encounter_id, person_id, encounter_datetime);

CREATE INDEX mamba_z_encounter_obs_id_index
    ON mamba_z_encounter_obs (obs_id);

CREATE INDEX mamba_z_encounter_obs_encounter_id_index
    ON mamba_z_encounter_obs (encounter_id);

CREATE INDEX mamba_z_encounter_obs_encounter_type_uuid_index
    ON mamba_z_encounter_obs (encounter_type_uuid);

CREATE INDEX mamba_z_encounter_obs_question_concept_id_index
    ON mamba_z_encounter_obs (obs_question_concept_id);

CREATE INDEX mamba_z_encounter_obs_value_coded_index
    ON mamba_z_encounter_obs (obs_value_coded);

CREATE INDEX mamba_z_encounter_obs_value_coded_uuid_index
    ON mamba_z_encounter_obs (obs_value_coded_uuid);

CREATE INDEX mamba_z_encounter_obs_question_uuid_index
    ON mamba_z_encounter_obs (obs_question_uuid);

CREATE INDEX mamba_z_encounter_obs_status_index
    ON mamba_z_encounter_obs (status);

CREATE INDEX mamba_z_encounter_obs_voided_index
    ON mamba_z_encounter_obs (voided);

CREATE INDEX mamba_z_encounter_obs_row_num_index
    ON mamba_z_encounter_obs (row_num);

CREATE INDEX mamba_z_encounter_obs_encounter_datetime_index
    ON mamba_z_encounter_obs (encounter_datetime);

CREATE INDEX mamba_z_encounter_obs_person_id_index
    ON mamba_z_encounter_obs (person_id);

CREATE INDEX mamba_z_encounter_obs_date_voided_index
    ON mamba_z_encounter_obs (date_voided);

CREATE INDEX mamba_z_encounter_obs_incremental_record_index
    ON mamba_z_encounter_obs (incremental_record);

CREATE INDEX mamba_z_encounter_obs_order_id_index
    ON mamba_z_encounter_obs (order_id);

CREATE INDEX mamba_z_encounter_obs_previous_version_index
    ON mamba_z_encounter_obs (previous_version);

CREATE INDEX mamba_z_encounter_obs_obs_group_id_index
    ON mamba_z_encounter_obs (obs_group_id);

-- $END