DROP FUNCTION IF EXISTS fn_mamba_age_calculator;

DELIMITER //

CREATE FUNCTION fn_mamba_age_calculator(birthdate DATE, deathDate DATE) RETURNS INTEGER
    DETERMINISTIC
BEGIN
    DECLARE today DATE;
    DECLARE age INT;

    -- Check if birthdate is not null and not an empty string
    IF birthdate IS NULL OR TRIM(birthdate) = '' THEN
        RETURN NULL;
    ELSE
        SET today = IFNULL(CURDATE(), '0000-00-00');
        -- Check if birthdate is a valid date using STR_TO_DATE and if it's not in the future
        IF STR_TO_DATE(birthdate, '%Y-%m-%d') IS NULL OR STR_TO_DATE(birthdate, '%Y-%m-%d') > today THEN
            RETURN NULL;
        END IF;

        -- If deathDate is provided and in the past, set today to deathDate
        IF deathDate IS NOT NULL AND today > deathDate THEN
            SET today = deathDate;
        END IF;

        SET age = YEAR(today) - YEAR(birthdate);

        -- Adjust age based on month and day
        IF MONTH(today) < MONTH(birthdate) OR (MONTH(today) = MONTH(birthdate) AND DAY(today) < DAY(birthdate)) THEN
            SET age = age - 1;
        END IF;

        RETURN age;
    END IF;
END //

DELIMITER ;
