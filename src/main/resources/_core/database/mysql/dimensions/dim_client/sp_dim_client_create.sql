-- $BEGIN
CREATE TABLE dim_client (
    id INT NOT NULL AUTO_INCREMENT,
    client_id INT,
    date_of_birth DATE NULL,
    age INT,
    sex VARCHAR(255) NULL,
    county VARCHAR(255) NULL,
    sub_county VARCHAR(255) NULL,
    ward VARCHAR(255) NULL,
    PRIMARY KEY (id)
);
-- $END
