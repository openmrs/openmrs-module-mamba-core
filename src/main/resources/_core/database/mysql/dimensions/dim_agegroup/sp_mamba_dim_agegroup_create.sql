-- $BEGIN

CREATE TABLE mamba_dim_agegroup
(
    id              INT         NOT NULL AUTO_INCREMENT,
    age             INT         NULL,
    datim_agegroup  VARCHAR(50) NULL,
    normal_agegroup VARCHAR(50) NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

-- $END