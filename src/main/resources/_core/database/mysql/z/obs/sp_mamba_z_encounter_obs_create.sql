-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    encounter_id            INT           NULL,
    person_id               INT           NOT NULL,
    encounter_datetime      DATETIME      NOT NULL,
    obs_datetime            DATETIME      NOT NULL,
    obs_question_concept_id INT DEFAULT 0 NOT NULL,
    obs_value_text          TEXT          NULL,
    obs_value_numeric       DOUBLE        NULL,
    obs_value_coded         INT           NULL,
    obs_value_datetime      DATETIME      NULL,
    obs_value_complex       VARCHAR(1000) NULL,
    obs_value_drug          INT           NULL,
    obs_question_uuid       CHAR(38),
    obs_answer_uuid         CHAR(38),
    obs_value_coded_uuid    CHAR(38),
    encounter_type_uuid     CHAR(38)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_z_encounter_obs_encounter_id_type_uuid_person_id_index
    ON mamba_z_encounter_obs (encounter_id, encounter_type_uuid, person_id);

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

-- $END