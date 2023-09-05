DELIMITER //

DROP FUNCTION IF EXISTS fn_mamba_age_calculator;

CREATE FUNCTION fn_mamba_age_calculator(birthdate DATE, deathDate DATE) RETURNS Integer
    DETERMINISTIC
BEGIN
    DECLARE onDate DATE;
    DECLARE today DATE;
    DECLARE bday DATE;
    DECLARE age INT;
    DECLARE todaysMonth INT;
    DECLARE bdayMonth INT;
    DECLARE todaysDay INT;
    DECLARE bdayDay INT;
    DECLARE birthdateCheck VARCHAR(255) DEFAULT NULL;

    SET onDate = NULL;

    -- Check if birthdate is not null and not an empty string
    IF birthdate IS NULL OR TRIM(birthdate) = '' THEN
        RETURN NULL;
    ELSE
        SET today = CURDATE();

        -- Check if birthdate is a valid date using STR_TO_DATE &  -- Check if birthdate is not in the future
        SET birthdateCheck = STR_TO_DATE(birthdate, '%Y-%m-%d');
        IF birthdateCheck IS NULL OR birthdateCheck > today THEN
            RETURN NULL;
        END IF;

        IF onDate IS NOT NULL THEN
            SET today = onDate;
        END IF;

        IF deathDate IS NOT NULL AND today > deathDate THEN
            SET today = deathDate;
        END IF;

        SET bday = birthdate;
        SET age = YEAR(today) - YEAR(bday);
        SET todaysMonth = MONTH(today);
        SET bdayMonth = MONTH(bday);
        SET todaysDay = DAY(today);
        SET bdayDay = DAY(bday);

        IF todaysMonth < bdayMonth THEN
            SET age = age - 1;
        ELSEIF todaysMonth = bdayMonth AND todaysDay < bdayDay THEN
            SET age = age - 1;
        END IF;

        RETURN age;
    END IF;
END //

DELIMITER ;