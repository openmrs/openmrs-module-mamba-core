-- $BEGIN

CREATE TABLE dim_agegroup
(
    dim_age_id      INT AUTO_INCREMENT PRIMARY KEY,
    age             INT                            NULL,
    datim_agegroup  CHAR(50) CHARACTER SET UTF8MB4 NULL,
    normal_agegroup CHAR(50) CHARACTER SET UTF8MB4 NULL
);

-- $END