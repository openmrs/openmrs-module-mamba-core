-- $BEGIN

CREATE TABLE mamba_multiselect_questions
(
    id                      INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    obs_id                  INT          NOT NULL,
    person_id               INT          NOT NULL,
    encounter_id            INT          NOT NULL,
    obs_datetime            DATE         NOT NULL,
    obs_question_concept_id INT          NOT NULL,
    concept_name            VARCHAR(255) NOT NULL,
    obs_value_coded         INT          NOT NULL,

    INDEX mamba_idx_obs_id (obs_id),
    INDEX mamba_idx_encounter_id (encounter_id),
    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_obs_value_coded (obs_value_coded),
    INDEX mamba_idx_obs_question_concept_id (obs_question_concept_id)
)
    CHARSET = UTF8MB4;

-- $END