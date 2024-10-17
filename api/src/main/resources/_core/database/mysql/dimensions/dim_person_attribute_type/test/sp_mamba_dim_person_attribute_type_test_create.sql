-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_attribute_type_create procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_attribute_type_create;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_attribute_type_create()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing table before running the test
DROP TABLE IF EXISTS mamba_dim_person_attribute_type;

-- Step 3: Call the sp_mamba_dim_person_attribute_type_create procedure to create the table
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to create mamba_dim_person_attribute_type table via sp_mamba_dim_person_attribute_type_create.';
END;

        -- Call the stored procedure to create the table
CALL sp_mamba_dim_person_attribute_type_create();
END;

    -- Step 4: Validate the creation of the table
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'mamba_dim_person_attribute_type') THEN
        SET test_failed = 1;
        SET failed_message = 'Table mamba_dim_person_attribute_type was not created by sp_mamba_dim_person_attribute_type_create.';
END IF;

    -- Step 5: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
SELECT 'Unit Test Passed: mamba_dim_person_attribute_type table created successfully via sp_mamba_dim_person_attribute_type_create.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_attribute_type_create();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_attribute_type_create;

-- $END
