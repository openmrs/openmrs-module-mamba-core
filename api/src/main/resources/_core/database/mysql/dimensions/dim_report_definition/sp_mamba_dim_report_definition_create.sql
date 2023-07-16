-- $BEGIN

CREATE TABLE IF NOT EXISTS mamba_dim_report_definition -- TODO: REMOVE the 'NOT EXISTS PART once the insert is automated'
(
    id                    INT          NOT NULL AUTO_INCREMENT,
    report_id             VARCHAR(255) NOT NULL,
    report_procedure_name VARCHAR(255) NOT NULL,
    report_name           VARCHAR(255) NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_report_definition_report_id_index
    ON mamba_dim_report_definition (report_id);

-- $END
