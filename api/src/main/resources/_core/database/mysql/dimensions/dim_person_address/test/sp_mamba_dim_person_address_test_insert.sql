-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_address_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_address_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_address_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing records before running the test
DELETE FROM mamba_dim_person_address;

-- Step 3: Call the sp_mamba_dim_person_address_insert procedure to insert a test record
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert record into mamba_dim_person_address via sp_mamba_dim_person_address_insert.';
            -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_address_insert', 'FAILED', failed_message, NOW());
END;

        -- Call the stored procedure to insert a record
CALL sp_mamba_dim_person_address_insert();
END;

    -- Step 4: Validate the insertion of the record
    IF (SELECT COUNT(*) FROM mamba_dim_person_address) = 0 THEN
        SET test_failed = 1;
SET failed_message = 'No records found in mamba_dim_person_address after insertion.';
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_address_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 5: Validate the inserted record
    DECLARE expected_person_id INT DEFAULT 123;
    DECLARE actual_person_id INT;

SELECT person_id INTO actual_person_id FROM mamba_dim_person_address WHERE person_address_id = 1;

IF actual_person_id != expected_person_id THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Expected person_id: ', expected_person_id, ', but found: ', actual_person_id);
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_address_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 6: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
        -- Log the success message into _mamba_etl_test_log
        INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
        VALUES ('test_sp_mamba_dim_person_address_insert', 'PASSED', 'Record inserted successfully into mamba_dim_person_address.', NOW());
SELECT 'Unit Test Passed: Record inserted successfully into mamba_dim_person_address.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_address_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_address_insert;


-- $END
