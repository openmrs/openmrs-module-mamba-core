-- $BEGIN

CREATE TABLE mamba_dim_encounter
(
    encounter_id               INT                            NOT NULL AUTO_INCREMENT,
    external_encounter_id      INT,
    external_encounter_type_id INT,
    encounter_type_uuid        CHAR(38) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (encounter_id)
);

CREATE INDEX mamba_dim_encounter_ext_encounter_id_index
    ON mamba_dim_encounter (external_encounter_id);

CREATE INDEX mamba_dim_encounter_type_ext_encounter_id_index
    ON mamba_dim_encounter (external_encounter_type_id);

CREATE INDEX mamba_dim_encounter_encounter_type_uuid_index
    ON mamba_dim_encounter (encounter_type_uuid);

-- $END
