-- $BEGIN

CREATE TABLE mamba_dim_person_address
(
    person_address_id          INT                             NOT NULL AUTO_INCREMENT,
    external_person_address_id INT,
    external_person_id         INT,
    city_village               CHAR(255) CHARACTER SET UTF8MB4 NULL,
    county_district            CHAR(255) CHARACTER SET UTF8MB4 NULL,
    address1                   CHAR(255) CHARACTER SET UTF8MB4 NULL,
    address2                   CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (person_address_id)
);

CREATE INDEX mamba_dim_person_address_external_person_id_index
    ON mamba_dim_person_address (external_person_id);

CREATE INDEX mamba_dim_person_address_external_person_address_id_index
    ON mamba_dim_person_address (external_person_address_id);

-- $END
