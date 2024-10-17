-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_address_create procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_address_create;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_address_create()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing table before running the test
DROP TABLE IF EXISTS mamba_dim_person_address;

-- Step 3: Call the sp_mamba_dim_person_address_create procedure to create the table
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to create mamba_dim_person_address table via sp_mamba_dim_person_address_create.';
            -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_address_create', 'FAILED', failed_message, NOW());
END;

        -- Call the stored procedure to create the table
CALL sp_mamba_dim_person_address_create();
END;

    -- Step 4: Validate the creation of the table
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'mamba_dim_person_address') THEN
        SET test_failed = 1;
        SET failed_message = 'Table mamba_dim_person_address was not created by sp_mamba_dim_person_address_create.';
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_address_create', 'FAILED', failed_message, NOW());
END IF;

    -- Step 5: Validate the structure of the created table
    DECLARE expected_columns VARCHAR(255) DEFAULT 'person_address_id, person_id, preferred, address1, address2, address3, address4, address5, address6, address7, address8, address9, address10, address11, address12, address13, address14, address15, city_village, county_district, state_province, postal_code, country, latitude, longitude, date_created, date_changed, date_voided, changed_by, voided, voided_by, void_reason, incremental_record';
    DECLARE actual_columns VARCHAR(255);

SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) INTO actual_columns
FROM information_schema.columns
WHERE table_name = 'mamba_dim_person_address';

-- Check if the actual columns match the expected columns
IF actual_columns != expected_columns THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Table structure does not match. Expected: ', expected_columns, ' Found: ', actual_columns);
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_address_create', 'FAILED', failed_message, NOW());
END IF;

    -- Step 6: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
        -- Log the success message into _mamba_etl_test_log
        INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
        VALUES ('test_sp_mamba_dim_person_address_create', 'PASSED', 'mamba_dim_person_address table created successfully with the correct structure.', NOW());
SELECT 'Unit Test Passed: mamba_dim_person_address table created successfully with the correct structure.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_address_create();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_address_create;


-- $END
