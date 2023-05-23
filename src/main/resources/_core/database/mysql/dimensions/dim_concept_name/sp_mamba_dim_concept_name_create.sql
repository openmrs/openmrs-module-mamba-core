-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    id              INT          NOT NULL AUTO_INCREMENT,
    concept_name_id INT          NOT NULL,
    concept_id      INT,
    concept_name    VARCHAR(255) NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_concept_name_concept_name_id_index
    ON mamba_dim_concept_name (concept_name_id);

CREATE INDEX mamba_dim_concept_name_concept_id_index
    ON mamba_dim_concept_name (concept_id);

-- $END
