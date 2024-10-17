-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_location_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_location_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_location_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up test data before running the test
DELETE FROM mamba_dim_location;

-- Step 3: Insert test data using sp_mamba_dim_location_insert procedure
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert data into mamba_dim_location via sp_mamba_dim_location_insert.';
END;

        -- Call the stored procedure to insert data
CALL sp_mamba_dim_location_insert();
END;

    -- Step 4: Validate that the data has been inserted
    IF (SELECT COUNT(*) FROM mamba_dim_location) = 0 THEN
        SET test_failed = 1;
SET failed_message = 'No data was inserted into mamba_dim_location by sp_mamba_dim_location_insert.';
END IF;

    -- Step 5: Validate the content of the inserted data
    DECLARE expected_location_id INT DEFAULT 1;
    DECLARE actual_location_id INT;

    -- Assume the first location_id should be 1 for the test
SELECT location_id INTO actual_location_id FROM mamba_dim_location LIMIT 1;

IF actual_location_id != expected_location_id THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Incorrect location_id. Expected: ', expected_location_id, ', Found: ', actual_location_id);
END IF;

    -- Step 6: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
SELECT 'Unit Test Passed: Data inserted successfully into mamba_dim_location via sp_mamba_dim_location_insert.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_location_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_location_insert;


-- $END