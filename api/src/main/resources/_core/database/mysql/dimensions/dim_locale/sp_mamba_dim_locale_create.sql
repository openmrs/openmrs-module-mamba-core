-- $BEGIN

CREATE TABLE mamba_dim_locale
(
    id     INT        NOT NULL AUTO_INCREMENT,
    locale VARCHAR(4) NOT NULL UNIQUE DEFAULT 'en',

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

-- $END
