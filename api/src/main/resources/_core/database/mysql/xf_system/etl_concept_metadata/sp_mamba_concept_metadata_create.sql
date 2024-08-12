-- $BEGIN

CREATE TABLE mamba_concept_metadata
(
    id                  INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    concept_id          INT          NULL,
    concept_uuid        CHAR(38)     NOT NULL,
    concept_name        VARCHAR(255) NULL,
    column_number       INT,
    column_label        VARCHAR(60)  NOT NULL,
    concept_datatype    VARCHAR(255) NULL,
    concept_answer_obs  TINYINT      NOT NULL DEFAULT 0,
    report_name         VARCHAR(255) NOT NULL,
    flat_table_name     VARCHAR(60)  NULL,
    encounter_type_uuid CHAR(38)     NOT NULL,
    row_num             INT          NULL     DEFAULT 1,
    incremental_record  INT          NOT NULL DEFAULT 0,

    INDEX mamba_idx_concept_id (concept_id),
    INDEX mamba_idx_concept_uuid (concept_uuid),
    INDEX mamba_idx_encounter_type_uuid (encounter_type_uuid),
    INDEX mamba_idx_row_num (row_num),
    INDEX mamba_idx_concept_datatype (concept_datatype),
    INDEX mamba_idx_flat_table_name (flat_table_name),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END