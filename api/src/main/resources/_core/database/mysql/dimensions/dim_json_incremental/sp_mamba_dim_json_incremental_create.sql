-- $BEGIN

CREATE TABLE mamba_dim_json_incremental
(
    id                INT          NOT NULL AUTO_INCREMENT,
    report_name       VARCHAR(100) NOT NULL,
    encounter_type_id INT          NOT NULL UNIQUE,
    Json_data         JSON,
    uuid              CHAR(38),
    Json_data_hash    CHAR(32),

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_json_incremental_encounter_type_id_index
    ON mamba_dim_json_incremental (encounter_type_id);

CREATE INDEX mamba_dim_json_incremental_report_name_index
    ON mamba_dim_json_incremental (report_name);

CREATE INDEX mamba_dim_json_incremental_uuid_index
    ON mamba_dim_json_incremental (uuid);

CREATE INDEX mamba_dim_json_incremental_Json_data_hash_index
    ON mamba_dim_json_incremental (Json_data_hash);

-- $END
