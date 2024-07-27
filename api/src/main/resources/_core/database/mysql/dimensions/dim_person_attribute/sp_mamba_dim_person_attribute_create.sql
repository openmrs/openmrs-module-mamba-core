-- $BEGIN

CREATE TABLE mamba_dim_person_attribute
(
    person_attribute_id      INT           NOT NULL UNIQUE PRIMARY KEY,
    person_attribute_type_id INT           NOT NULL,
    person_id                INT           NOT NULL,
    uuid                     CHAR(38)      NOT NULL,
    value                    NVARCHAR(50)  NOT NULL,
    voided                   TINYINT,
    date_created             DATETIME      NOT NULL,
    date_changed             DATETIME      NULL,
    date_voided              DATETIME      NULL,
    changed_by               INT           NULL,
    voided_by                INT           NULL,
    void_reason              VARCHAR(255)  NULL,
    incremental_record       INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_person_attribute_type_id (person_attribute_type_id),
    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_uuid (uuid),
    INDEX mamba_idx_voided (voided),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
