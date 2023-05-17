-- $BEGIN

CREATE TABLE mamba_dim_encounter_type
(
    encounter_type_id          INT                            NOT NULL AUTO_INCREMENT,
    external_encounter_type_id INT,
    encounter_type_uuid        CHAR(38) CHARACTER SET UTF8MB4 NOT NULL,
    PRIMARY KEY (encounter_type_id)
);

CREATE INDEX mamba_dim_encounter_type_ext_encounter_id_index
    ON mamba_dim_encounter_type (external_encounter_type_id);

CREATE INDEX mamba_dim_encounter_type_encounter_type_uuid_index
    ON mamba_dim_encounter_type (encounter_type_uuid);
-- $END
