-- $BEGIN

CREATE TABLE IF NOT EXISTS mamba_flat_table_config_incremental
(
    id                   INT           NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    encounter_type_id    INT           NOT NULL UNIQUE,
    report_name          VARCHAR(100)  NOT NULL,
    table_json_data      JSON          NOT NULL,
    table_json_data_hash CHAR(32)      NULL,
    encounter_type_uuid  CHAR(38)      NOT NULL,
    incremental_record   INT DEFAULT 0 NOT NULL COMMENT 'Whether `table_json_data` has been modified or not',

    INDEX mamba_idx_encounter_type_id (encounter_type_id),
    INDEX mamba_idx_report_name (report_name),
    INDEX mamba_idx_table_json_data_hash (table_json_data_hash),
    INDEX mamba_idx_uuid (encounter_type_uuid),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END