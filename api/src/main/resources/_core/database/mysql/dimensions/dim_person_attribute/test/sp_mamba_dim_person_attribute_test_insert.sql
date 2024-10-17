-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_attribute_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_attribute_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_attribute_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing records before running the test
DELETE FROM mamba_dim_person_attribute;

-- Step 3: Call the sp_mamba_dim_person_attribute_insert procedure to insert a record
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert record into mamba_dim_person_attribute via sp_mamba_dim_person_attribute_insert.';
END;

        -- Call the stored procedure to insert the record
CALL sp_mamba_dim_person_attribute_insert();
END;

    -- Step 4: Validate the insertion of the record
    IF NOT EXISTS (SELECT * FROM mamba_dim_person_attribute WHERE person_attribute_id = 1) THEN
        SET test_failed = 1;
        SET failed_message = 'Record was not inserted into mamba_dim_person_attribute.';
END IF;

    -- Step 5: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
SELECT 'Unit Test Passed: Record inserted successfully into mamba_dim_person_attribute.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_attribute_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_attribute_insert;

-- $END
