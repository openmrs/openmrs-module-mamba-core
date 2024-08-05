-- $BEGIN

CREATE TABLE mamba_z_encounter_obs
(
    obs_id                  INT           NOT NULL UNIQUE PRIMARY KEY,
    encounter_id            INT           NULL,
    visit_id                INT           NULL,
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

    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_visit_id (visit_id),
    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_encounter_datetime (encounter_datetime),
    INDEX mamba_idx_encounter_type_uuid (encounter_type_uuid),
    INDEX mamba_idx_obs_question_concept_id (obs_question_concept_id),
    INDEX mamba_idx_obs_value_coded (obs_value_coded),
    INDEX mamba_idx_obs_value_coded_uuid (obs_value_coded_uuid),
    INDEX mamba_idx_obs_question_uuid (obs_question_uuid),
    INDEX mamba_idx_status (status),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_row_num (row_num),
    INDEX mamba_idx_date_voided (date_voided),
    INDEX mamba_idx_order_id (order_id),
    INDEX mamba_idx_previous_version (previous_version),
    INDEX mamba_idx_obs_group_id (obs_group_id),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END