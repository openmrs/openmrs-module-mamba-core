-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    encounter_id               INT                  NOT NULL AUTO_INCREMENT,
    external_encounter_id      INT,
    external_encounter_type_id INT,
    encounter_type_uuid        CHAR(38)             NULL,

    patient_id                 INT        DEFAULT 0 NOT NULL,
    encounter_datetime         DATETIME             NOT NULL,
    date_created               DATETIME             NOT NULL,
    voided                     TINYINT(1) DEFAULT 0 NOT NULL,
    visit_id                   INT                  NULL,

    PRIMARY KEY (encounter_id)
) CHARSET = UTF8MB4;

-- $END
