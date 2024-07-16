-- $BEGIN

CREATE TABLE mamba_dim_person_attribute
(
    id                    INT         NOT NULL AUTO_INCREMENT,
    date_created                DATETIME    NOT NULL,
    person_attribute_id         INT         NOT NULL,
    person_attribute_type_id    INT         NOT NULL,
    person_id                   INT         NOT NULL,
    uuid                        CHAR(38)    NOT NULL,
    value                       NVARCHAR(50) NOT NULL,
    voided                      TINYINT(1)   NOT NULL,
    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_person_attribute_person_attribute_id_index
    ON mamba_dim_person_attribute (person_attribute_id);

CREATE INDEX mamba_dim_person_attribute_person_attribute_type_id_index
    ON mamba_dim_person_attribute (person_attribute_type_id);

CREATE INDEX mamba_dim_person_attribute_person_id_index
    ON mamba_dim_person_attribute (person_id);

CREATE INDEX mamba_dim_person_attribute_uuid_index
    ON mamba_dim_person_attribute (uuid);

-- $END
