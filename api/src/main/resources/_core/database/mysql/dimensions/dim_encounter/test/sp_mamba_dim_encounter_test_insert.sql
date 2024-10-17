-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_concept_name_insert
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_name_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_concept_name_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Setup - Ensure the source table exists and insert test data
    TRUNCATE TABLE mamba_source_db.concept_name;

    INSERT INTO mamba_source_db.concept_name (concept_name_id, concept_id, name, locale, locale_preferred, concept_name_type, voided, date_created)
    VALUES
        (1, 101, 'Test Concept Name 1', 'en', 1, 'FULLY_SPECIFIED', 0, NOW()), -- Valid entry
        (2, 102, 'Test Concept Name 2', 'fr', 0, 'FULLY_SPECIFIED', 0, NOW()), -- Valid entry
        (3, 103, 'Test Concept Name 3', 'en', 0, 'FULLY_SPECIFIED', 1, NOW()), -- Voided entry
        (4, 104, 'Test Concept Name 4', 'es', 0, 'FULLY_SPECIFIED', 0, NOW()); -- Locale not in _mamba_etl_user_settings

    -- Step 3: Insert relevant data into `_mamba_etl_user_settings` for locale filtering
    TRUNCATE TABLE _mamba_etl_user_settings;

    INSERT INTO _mamba_etl_user_settings (concepts_locale)
    VALUES ('en'), ('fr'); -- Only 'en' and 'fr' should be considered during insert

    -- Step 4: Clear the target table before running the insert procedure
    TRUNCATE TABLE mamba_dim_concept_name;

    -- Step 5: Execute the procedure to be tested
    BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
                SET test_failed = 1;
                SET failed_message = 'Procedure sp_mamba_dim_concept_name_insert failed.';
    END;

            -- Call the procedure to insert data from mamba_source_db.concept_name into mamba_dim_concept_name
    CALL sp_mamba_dim_concept_name_insert();
    END;

    -- Step 6: Validate the data inserted into `mamba_dim_concept_name`
    -- Check for the expected rows
    IF (SELECT COUNT(*) FROM mamba_dim_concept_name) <> 2 THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Expected 2 rows but found ', (SELECT COUNT(*) FROM mamba_dim_concept_name));
    END IF;

    -- Check for expected data
    IF NOT EXISTS (SELECT * FROM mamba_dim_concept_name WHERE concept_name_id = 1 AND locale = 'en') THEN
        SET test_failed = 1;
        SET failed_message = 'Expected row for concept_name_id = 1 with locale = en not found.';
    END IF;

    IF NOT EXISTS (SELECT * FROM mamba_dim_concept_name WHERE concept_name_id = 2 AND locale = 'fr') THEN
        SET test_failed = 1;
        SET failed_message = 'Expected row for concept_name_id = 2 with locale = fr not found.';
    END IF;

    -- Step 7: Log the test result
    IF test_failed = 1 THEN
        INSERT INTO _mamba_etl_test_log (test_name, result, message)
        VALUES ('test_sp_mamba_dim_concept_name_insert', 'FAILED', failed_message);
    ELSE
        INSERT INTO _mamba_etl_test_log (test_name, result, message)
        VALUES ('test_sp_mamba_dim_concept_name_insert', 'PASSED', 'All expected rows found.');
    END IF;
END //

DELIMITER ;

-- Call the unit test
CALL test_sp_mamba_dim_concept_name_insert();

-- Optionally, check the log for results
SELECT * FROM _mamba_etl_test_log;

-- $END
