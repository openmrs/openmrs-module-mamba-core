-- $BEGIN

CREATE TABLE mamba_dim_json
(
    report_name             VARCHAR(100) NOT NULL,
    encounter_type_id       INT NOT NULL UNIQUE,
    Json_data               JSON,

    PRIMARY KEY (encounter_type_id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_json_encounter_type_id_index
    ON mamba_dim_json (encounter_type_id);

CREATE INDEX mamba_dim_json_report_name_index
    ON mamba_dim_json (report_name);

-- $END
