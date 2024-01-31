DROP FUNCTION IF EXISTS fn_mamba_calculate_agegroup;

DELIMITER //

CREATE FUNCTION fn_mamba_calculate_agegroup(age INT) RETURNS VARCHAR(15)
    DETERMINISTIC
BEGIN
    DECLARE agegroup VARCHAR(15);
    CASE
        WHEN age < 1 THEN  agegroup = '<1';
        WHEN age between 1 and 4 THEN  agegroup = '1-4';
        WHEN age between 5 and 9 THEN  agegroup = '5-9';
        WHEN age between 10 and 14 THEN  agegroup = '10-14';
        WHEN age between 15 and 19 THEN  agegroup = '15-19';
        WHEN age between 20 and 24 THEN  agegroup = '20-24';
        WHEN age between 25 and 29 THEN  agegroup = '25-29';
        WHEN age between 30 and 34 THEN  agegroup = '30-34';
        WHEN age between 35 and 39 THEN  agegroup = '35-39';
        WHEN age between 40 and 44 THEN  agegroup = '40-44';
        WHEN age between 45 and 49 THEN  agegroup = '45-49';
        WHEN age between 50 and 54 THEN  agegroup = '50-54';
        WHEN age between 55 and 59 THEN  agegroup = '55-59';
        WHEN age between 60 and 64 THEN  agegroup = '60-64';
        WHEN  agegroup = '65+';
    END CASE;

    RETURN agegroup;

END //

DELIMITER ;