DELIMITER //

DROP PROCEDURE IF EXISTS sp_load_agegroup;

CREATE PROCEDURE sp_load_agegroup()
BEGIN
    DECLARE age INT DEFAULT 0;
    WHILE age <= 120
        DO
            INSERT INTO dim_agegroup(age, datim_agegroup, normal_agegroup)
            VALUES (age, fn_calculate_agegroup(age), IF(age < 15, '<15', '15+'));
            SET age = age + 1;
        END WHILE;
END //

DELIMITER ;