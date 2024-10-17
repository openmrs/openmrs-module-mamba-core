-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_name_create procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_name_create;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_name_create()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing table before running the test
DROP TABLE IF EXISTS mamba_dim_person_name;

-- Step 3: Call the sp_mamba_dim_person_name_create procedure to create the table
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to create mamba_dim_person_name table via sp_mamba_dim_person_name_create.';
END;

        -- Call the stored procedure to create the table
CALL sp_mamba_dim_person_name_create();
END;

    -- Step 4: Validate the creation of the table
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'mamba_dim_person_name') THEN
        SET test_failed = 1;
        SET failed_message = 'Table mamba_dim_person_name was not created by sp_mamba_dim_person_name_create.';
END IF;

    -- Step 5: Validate the structure of the created table
    DECLARE expected_columns VARCHAR(255) DEFAULT 'person_name_id, person_id, preferred, given_name, family_name, middle_name, honorific_prefix, honorific_suffix, uuid, date_created, date_changed, changed_by, date_voided, voided, voided_by, void_reason, incremental_record';
    DECLARE actual_columns VARCHAR(255);

SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) INTO actual_columns
FROM information_schema.columns
WHERE table_name = 'mamba_dim_person_name';

-- Check if the actual columns match the expected columns
IF actual_columns != expected_columns THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Table structure does not match. Expected: ', expected_columns, ' Found: ', actual_columns);
END IF;

    -- Step 6: Log the test result
INSERT INTO mamba_etl_test_log (test_name, log_message)
VALUES ('test_sp_mamba_dim_person_name_create', IF(test_failed = 1, CONCAT('Unit Test Failed: ', failed_message), 'Unit Test Passed: mamba_dim_person_name table created successfully via sp_mamba_dim_person_name_create with the correct structure.'));

-- Step 7: Return result
IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
SELECT 'Unit Test Passed: mamba_dim_person_name table created successfully via sp_mamba_dim_person_name_create with the correct structure.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_name_create();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_name_create;


-- $END
