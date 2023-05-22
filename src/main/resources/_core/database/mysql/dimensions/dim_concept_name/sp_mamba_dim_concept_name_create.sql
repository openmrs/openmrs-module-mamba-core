-- $BEGIN

CREATE TABLE mamba_dim_concept_name
(
    concept_name_id     INT          NOT NULL AUTO_INCREMENT,
    external_concept_id INT,
    concept_name        VARCHAR(255) NULL,

    PRIMARY KEY (concept_name_id)
)
    CHARSET = UTF8MB4;

-- $END
