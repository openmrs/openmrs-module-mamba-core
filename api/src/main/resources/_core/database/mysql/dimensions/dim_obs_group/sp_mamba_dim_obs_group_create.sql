-- $BEGIN

CREATE TABLE mamba_dim_obs_group
(
    id                   INT          NOT NULL AUTO_INCREMENT,
    obs_group_concept_id INT          NOT NULL,
    obs_group_name       VARCHAR(255) NOT NULL, -- should be the concept name of the obs
    obs_id               INT          NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_obs_group_concept_id_index
    ON mamba_dim_obs_group (obs_group_concept_id);

CREATE INDEX mamba_dim_obs_group_id_index
    ON mamba_dim_obs_group (obs_id);


-- $END
