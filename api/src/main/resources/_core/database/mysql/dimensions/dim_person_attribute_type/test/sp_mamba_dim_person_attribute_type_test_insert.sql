-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_attribute_type_insert procedure (without parameters)
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_attribute_type_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_attribute_type_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing data
DELETE FROM mamba_dim_person_attribute_type;

-- Step 3: Insert a test record using sp_mamba_dim_person_attribute_type_insert procedure
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert data via sp_mamba_dim_person_attribute_type_insert.';
END;

        -- Call the stored procedure to insert a test record without passing parameters
CALL sp_mamba_dim_person_attribute_type_insert();
END;

    -- Step 4: Validate the insert operation
    IF NOT EXISTS (SELECT * FROM mamba_dim_person_attribute_type WHERE uuid IS NOT NULL ORDER BY  person_attribute_type_id DESC LIMIT 1 ) THEN
        SET test_failed = 1;
        SET failed_message = 'Record was not inserted into mamba_dim_person_attribute_type.';
    END IF;

    -- Step 5: Validate specific field values
    DECLARE expected_name VARCHAR(50) DEFAULT 'Test Attribute Type';
    DECLARE actual_name VARCHAR(50);

SELECT name INTO actual_name
FROM mamba_dim_person_attribute_type
WHERE uuid = 'test-uuid-123';

IF actual_name != expected_name THEN
        SET test_failed = 1;
        SET failed_message = 'Record insert did not match expected values.';
END IF;

    -- Step 6: Log results to the test log table
    IF test_failed = 1 THEN
        INSERT INTO _mamba_etl_test_log (test_description, test_result)
        VALUES ('Unit Test: sp_mamba_dim_person_attribute_type_insert', CONCAT('Failed: ', failed_message));
ELSE
        INSERT INTO _mamba_etl_test_log (test_description, test_result)
        VALUES ('Unit Test: sp_mamba_dim_person_attribute_type_insert', 'Passed');
END IF;

    -- Step 7: Return result of the unit test
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
SELECT 'Unit Test Passed: sp_mamba_dim_person_attribute_type_insert worked as expected.' AS result;
END IF;


END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_attribute_type_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_attribute_type_insert;


-- $END
