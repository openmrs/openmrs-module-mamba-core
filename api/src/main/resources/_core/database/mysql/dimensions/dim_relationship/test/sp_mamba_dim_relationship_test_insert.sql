-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_relationship_insert procedure without parameters
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_relationship_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_relationship_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing records in the mamba_dim_relationship table
DELETE FROM mamba_dim_relationship WHERE relationship_id = 1;

-- Step 3: Call the sp_mamba_dim_relationship_insert procedure to insert a test record
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert record into mamba_dim_relationship.';
END;

        -- Call the stored procedure without parameters
CALL sp_mamba_dim_relationship_insert();
END;

    -- Step 4: Validate that the record was inserted successfully
    IF NOT EXISTS (SELECT * FROM mamba_dim_relationship WHERE relationship_id = 1) THEN
        SET test_failed = 1;
        SET failed_message = 'Record not found in mamba_dim_relationship after insert.';
END IF;

    -- Step 5: Log the result
    IF test_failed = 1 THEN
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES ('test_sp_mamba_dim_relationship_insert', CONCAT('Unit Test Failed: ', failed_message));
ELSE
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES ('test_sp_mamba_dim_relationship_insert', 'Unit Test Passed: Record inserted successfully.');
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_relationship_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_relationship_insert;

-- $END
