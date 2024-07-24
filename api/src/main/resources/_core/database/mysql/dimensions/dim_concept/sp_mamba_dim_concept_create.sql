-- $BEGIN

CREATE TABLE mamba_dim_concept
(
    id                 INT           NOT NULL AUTO_INCREMENT,
    concept_id         INT           NOT NULL,
    uuid               CHAR(38)      NOT NULL,
    datatype_id        INT           NOT NULL, -- make it a FK
    datatype           VARCHAR(100)  NULL,
    name               VARCHAR(256)  NULL,
    retired            TINYINT(1)    NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_retired       DATETIME      NULL,
    retired_by         INT           NULL,
    retire_reason      VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_concept_concept_id_index
    ON mamba_dim_concept (concept_id);

CREATE INDEX mamba_dim_concept_uuid_index
    ON mamba_dim_concept (uuid);

CREATE INDEX mamba_dim_concept_datatype_id_index
    ON mamba_dim_concept (datatype_id);

CREATE INDEX mamba_dim_concept_retired_index
    ON mamba_dim_concept (retired);

CREATE INDEX mamba_dim_concept_incremental_record_index
    ON mamba_dim_concept (incremental_record);

CREATE INDEX mamba_dim_concept_date_created_index
    ON mamba_dim_concept (date_created);

-- $END
