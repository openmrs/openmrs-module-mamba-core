-- $BEGIN

CREATE TABLE mamba_dim_person_address (
    person_address_id int NOT NULL AUTO_INCREMENT,
    external_person_address_id int,
    external_person_id int,
    city_village VARCHAR(255) NULL,
    county_district VARCHAR(255) NULL,
    address1 VARCHAR(255) NULL,
    address2 VARCHAR(255) NULL,
    PRIMARY KEY (person_address_id)
);
create index mamba_dim_person_address_external_person_id_index
    on mamba_dim_person_address (external_person_id);

-- $END
