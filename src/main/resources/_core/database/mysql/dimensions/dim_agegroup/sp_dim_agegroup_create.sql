-- $BEGIN

CREATE TABLE dim_agegroup(
    dim_age_id int auto_increment primary key,
    age int NULL,
    datim_agegroup CHAR(50) CHARACTER SET UTF8MB4 NULL,
    normal_agegroup CHAR(50) CHARACTER SET UTF8MB4 NULL
);

-- $END