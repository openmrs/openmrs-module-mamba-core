-- $BEGIN

CREATE TABLE mamba_dim_encounter (
    encounter_id int NOT NULL AUTO_INCREMENT,
    external_encounter_id int,
    external_encounter_type_id int,
    encounter_type_uuid CHAR(38) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (encounter_id)
);

-- $END
