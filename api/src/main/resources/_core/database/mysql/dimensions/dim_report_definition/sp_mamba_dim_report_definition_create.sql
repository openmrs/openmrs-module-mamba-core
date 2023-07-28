-- $BEGIN

DROP TABLE IF EXISTS mamba_dim_report_definition;

CREATE TABLE mamba_dim_report_definition
(
    id                    INT          NOT NULL AUTO_INCREMENT,
    report_id             VARCHAR(255) NOT NULL,
    report_procedure_name VARCHAR(255) NOT NULL,
    report_name           VARCHAR(255) NULL,
    parameter_name        VARCHAR(255) NULL,
    parameter_type        VARCHAR(255) NULL,
    parameter_position    INT,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_report_definition_report_id_index
    ON mamba_dim_report_definition (report_id);

-- $END
