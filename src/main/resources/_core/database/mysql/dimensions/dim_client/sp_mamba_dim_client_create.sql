-- $BEGIN

CREATE TABLE mamba_dim_client
(
    id            INT                  NOT NULL AUTO_INCREMENT,
    client_id     INT,
    date_of_birth DATE                 NULL,
    age           INT,
    sex           VARCHAR(20)          NULL,
    county        VARCHAR(255)         NULL,
    sub_county    VARCHAR(255)         NULL,
    ward          VARCHAR(255)         NULL,
    date_created  DATETIME             NOT NULL,
    voided        TINYINT(1) DEFAULT 0 NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

-- $END
