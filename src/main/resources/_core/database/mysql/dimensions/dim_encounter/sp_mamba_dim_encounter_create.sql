-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    encounter_id               INT                            NOT NULL AUTO_INCREMENT,
    external_encounter_id      INT,
    external_encounter_type_id INT,
    encounter_type_uuid        CHAR(38) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (encounter_id)
);

-- $END
