-- $BEGIN

CREATE TABLE mamba_dim_concept_metadata
(
    concept_metadata_id INT          NOT NULL AUTO_INCREMENT,
    concept_id          INT,
    concept_uuid        CHAR(38)     NOT NULL,
    column_number       INT,
    column_label        VARCHAR(50)  NOT NULL,
    concept_datatype    VARCHAR(255) NULL,
    concept_answer_obs  TINYINT(1)   NOT NULL DEFAULT 0,
    report_name         VARCHAR(255) NOT NULL,
    flat_table_name     VARCHAR(255) NULL,
    encounter_type_uuid CHAR(38)     NOT NULL,

    PRIMARY KEY (concept_metadata_id)
)
    CHARSET = UTF8MB4;

create index mamba_dim_concept_metadata_concept_uuid_index
    on mamba_dim_concept_metadata (concept_uuid);

-- ALTER TABLE `mamba_dim_concept_metadata`
--     ADD COLUMN `encounter_type_id` INT NULL AFTER `output_table_name`,
--     ADD CONSTRAINT `fk_encounter_type_id`
--         FOREIGN KEY (`encounter_type_id`) REFERENCES `mamba_dim_encounter_type` (`encounter_type_id`);

-- $END
