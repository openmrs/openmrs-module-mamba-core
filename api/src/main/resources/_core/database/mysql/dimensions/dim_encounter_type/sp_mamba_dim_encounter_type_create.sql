-- $BEGIN

CREATE TABLE mamba_dim_encounter_type
(
    id                INT         NOT NULL AUTO_INCREMENT,
    encounter_type_id INT         NOT NULL,
    uuid              CHAR(38)    NOT NULL,
    name              VARCHAR(50) NOT NULL,
    flag              INT          NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_encounter_type_encounter_type_id_index
    ON mamba_dim_encounter_type (encounter_type_id);

CREATE INDEX mamba_dim_encounter_type_uuid_index
    ON mamba_dim_encounter_type (uuid);

-- $END
