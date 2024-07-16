-- $BEGIN

CREATE TABLE mamba_dim_person_attribute_type
(
    id                          INT           NOT NULL AUTO_INCREMENT,
    date_created                DATETIME      NOT NULL,
    description                 TEXT          NOT NULL,
    name                        NVARCHAR(50)    NOT NULL,
    person_attribute_type_id    INT             NOT NULL,
    retired                     TINYINT(1)      NOT NULL,
    searchable                  TINYINT(1)      NOT NULL,
    uuid                        NVARCHAR(50)    NOT NULL,
    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_person_attribute_type_person_attribute_type_id_index
    ON mamba_dim_person_attribute_type (person_attribute_type_id);

CREATE INDEX mamba_dim_person_attribute_type_name_index
    ON mamba_dim_person_attribute_type (name);

CREATE INDEX mamba_dim_person_attribute_type_uuid_index
    ON mamba_dim_person_attribute_type (uuid);

-- $END
