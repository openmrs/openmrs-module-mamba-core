-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    concept_name_id     INT                             NOT NULL AUTO_INCREMENT,
    external_concept_id INT,
    concept_name        CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (concept_name_id)
);

CREATE INDEX mamba_dim_concept_name_external_concept_id_index
    ON mamba_dim_concept_name (external_concept_id);

-- $END
