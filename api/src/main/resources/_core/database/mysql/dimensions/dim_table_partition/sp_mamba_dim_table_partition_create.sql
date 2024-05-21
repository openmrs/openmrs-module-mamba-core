-- $BEGIN

CREATE TABLE mamba_dim_table_partition
(
    id                     INT NOT NULL AUTO_INCREMENT,
    table_partition_number INT NOT NULL DEFAULT 100,

    PRIMARY KEY (id)
) CHARSET = UTF8MB4;

-- $END
