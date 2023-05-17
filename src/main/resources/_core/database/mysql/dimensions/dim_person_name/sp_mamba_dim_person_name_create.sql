-- $BEGIN

CREATE TABLE mamba_dim_person_name
(
    person_name_id          INT                             NOT NULL AUTO_INCREMENT,
    external_person_name_id INT,
    external_person_id      INT,
    given_name              CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (person_name_id)
);

CREATE INDEX mamba_dim_person_name_external_person_id_index
    ON mamba_dim_person_name (external_person_id);

CREATE INDEX mamba_dim_person_name_external_person_name_id_index
    ON mamba_dim_person_name (external_person_name_id);

-- $END
