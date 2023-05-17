-- $BEGIN

CREATE TABLE mamba_dim_person
(
    person_id          INT                             NOT NULL AUTO_INCREMENT,
    external_person_id INT,
    birthdate          CHAR(255) CHARACTER SET UTF8MB4 NULL,
    gender             CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (person_id)
);

CREATE INDEX mamba_dim_person_external_person_id_index
    ON mamba_dim_person (external_person_id);

-- $END
