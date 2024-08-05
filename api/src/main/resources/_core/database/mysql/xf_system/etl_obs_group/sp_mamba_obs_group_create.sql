-- $BEGIN

CREATE TABLE mamba_obs_group
(
    id                     INT          NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    obs_id                 INT          NOT NULL,
    obs_group_concept_id   INT          NOT NULL,
    obs_group_concept_name VARCHAR(255) NOT NULL, -- should be the concept name of the obs

    INDEX mamba_idx_obs_id (obs_id),
    INDEX mamba_idx_obs_group_concept_id (obs_group_concept_id)
)
    CHARSET = UTF8MB4;

-- $END