-- $BEGIN

CREATE TABLE mamba_dim_concept_metadata
(
    concept_metadata_id INT                             NOT NULL AUTO_INCREMENT,
    column_number       INT,
    column_label        CHAR(50) CHARACTER SET UTF8MB4  NOT NULL,
    concept_uuid        CHAR(38) CHARACTER SET UTF8MB4  NOT NULL,
    concept_datatype    CHAR(255) CHARACTER SET UTF8MB4 NULL,
    concept_answer_obs  TINYINT(1)                      NOT NULL DEFAULT 0,
    report_name         CHAR(255) CHARACTER SET UTF8MB4 NOT NULL,
    flat_table_name     CHAR(255) CHARACTER SET UTF8MB4 NULL,
    encounter_type_uuid CHAR(38) CHARACTER SET UTF8MB4  NOT NULL,

    PRIMARY KEY (concept_metadata_id)
);

CREATE INDEX mamba_dim_concept_metadata_concept_uuid_index
    ON mamba_dim_concept_metadata (concept_uuid);

CREATE INDEX mamba_dim_concept_metadata_encounter_type_uuid_index
    ON mamba_dim_concept_metadata (encounter_type_uuid);

CREATE INDEX mamba_dim_concept_metadata_concept_answer_obs_index
    ON mamba_dim_concept_metadata (concept_answer_obs);

CREATE INDEX mamba_dim_concept_metadata_flat_table_name_index
    ON mamba_dim_concept_metadata (flat_table_name);

-- ALTER TABLE `mamba_dim_concept_metadata`
--     ADD COLUMN `encounter_type_id` INT NULL AFTER `output_table_name`,
--     ADD CONSTRAINT `fk_encounter_type_id`
--         FOREIGN KEY (`encounter_type_id`) REFERENCES `mamba_dim_encounter_type` (`encounter_type_id`);

-- $END
