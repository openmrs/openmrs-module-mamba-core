-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_concept_insert
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_concept_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clear relevant test data in the target table for isolation
TRUNCATE TABLE mamba_dim_concept;

-- Step 3: Ensure the ETL settings table (_mamba_etl_user_settings) has relevant locales
DELETE FROM _mamba_etl_user_settings WHERE concepts_locale IN ('en', 'fr');
INSERT INTO _mamba_etl_user_settings (concepts_locale) VALUES ('en'), ('fr');

-- Step 4: Execute the procedure to be tested
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Procedure sp_mamba_dim_concept_insert failed.';
END;

        -- Call the procedure to insert data
CALL sp_mamba_dim_concept_insert();
END;

    -- Step 5: Validate the data inserted into `mamba_dim_concept`
    -- Assuming existing source data matches the criteria for insert
    IF NOT EXISTS (SELECT * FROM mamba_dim_concept WHERE concept_id IN (SELECT concept_id FROM openmrs.concept WHERE voided = 0) LIMIT 1) THEN
        SET test_failed = 1;
        SET failed_message = 'No expected rows found in mamba_dim_concept after insert.';
END IF;

    -- Check if there are duplicate entries for existing concepts
    IF (SELECT COUNT(*) FROM mamba_dim_concept WHERE concept_id IN (SELECT concept_id FROM openmrs.concept WHERE voided = 0)) >
       (SELECT COUNT(*) FROM openmrs.concept WHERE voided = 0) THEN
        SET test_failed = 1;
SET failed_message = 'Unexpected duplicate entries found in mamba_dim_concept.';
END IF;

    -- Step 6: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
SELECT 'Unit Test Passed: sp_mamba_dim_concept_insert executed successfully.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_concept_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_insert;
