-- $BEGIN

CREATE TABLE mamba_dim_person_address
(
    person_address_id  INT           NOT NULL UNIQUE PRIMARY KEY,
    person_id          INT           NULL,
    preferred          TINYINT       NOT NULL,
    address1           VARCHAR(255)  NULL,
    address2           VARCHAR(255)  NULL,
    address3           VARCHAR(255)  NULL,
    address4           VARCHAR(255)  NULL,
    address5           VARCHAR(255)  NULL,
    address6           VARCHAR(255)  NULL,
    address7           VARCHAR(255)  NULL,
    address8           VARCHAR(255)  NULL,
    address9           VARCHAR(255)  NULL,
    address10          VARCHAR(255)  NULL,
    address11          VARCHAR(255)  NULL,
    address12          VARCHAR(255)  NULL,
    address13          VARCHAR(255)  NULL,
    address14          VARCHAR(255)  NULL,
    address15          VARCHAR(255)  NULL,
    city_village       VARCHAR(255)  NULL,
    county_district    VARCHAR(255)  NULL,
    state_province     VARCHAR(255)  NULL,
    postal_code        VARCHAR(50)   NULL,
    country            VARCHAR(50)   NULL,
    latitude           VARCHAR(50)   NULL,
    longitude          VARCHAR(50)   NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    date_voided        DATETIME      NULL,
    changed_by         INT           NULL,
    voided             TINYINT,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL, -- whether a record has been inserted after the first ETL run

    INDEX mamba_idx_person_id (person_id),
    INDEX mamba_idx_preferred (preferred),
    INDEX mamba_idx_incremental_record (incremental_record)
)
    CHARSET = UTF8MB4;

-- $END
