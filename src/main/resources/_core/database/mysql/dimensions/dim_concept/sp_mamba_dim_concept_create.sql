-- $BEGIN

CREATE TABLE mamba_dim_concept
(
    concept_id           INT                             NOT NULL AUTO_INCREMENT,
    uuid                 CHAR(38) CHARACTER SET UTF8MB4  NOT NULL,
    external_concept_id  INT,
    external_datatype_id INT, -- make it a FK
    datatype             CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (concept_id)
);

CREATE INDEX mamba_dim_concept_external_concept_id_index
    ON mamba_dim_concept (external_concept_id);

CREATE INDEX mamba_dim_concept_external_datatype_id_index
    ON mamba_dim_concept (external_datatype_id);

-- $END
