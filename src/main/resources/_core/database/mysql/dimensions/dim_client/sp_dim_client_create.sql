-- $BEGIN
CREATE TABLE mamba_dim_client
(
    id            INT                             NOT NULL AUTO_INCREMENT,
    client_id     INT,
    date_of_birth DATE                            NULL,
    age           INT,
    sex           CHAR(255) CHARACTER SET UTF8MB4 NULL,
    county        CHAR(255) CHARACTER SET UTF8MB4 NULL,
    sub_county    CHAR(255) CHARACTER SET UTF8MB4 NULL,
    ward          CHAR(255) CHARACTER SET UTF8MB4 NULL,
    PRIMARY KEY (id)
);

create index mamba_dim_client_client_id_index
    on mamba_dim_client (client_id);

-- $END