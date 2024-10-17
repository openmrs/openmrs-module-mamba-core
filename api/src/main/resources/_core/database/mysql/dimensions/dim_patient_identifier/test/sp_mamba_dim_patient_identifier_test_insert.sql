-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_patient_identifier_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_patient_identifier_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_patient_identifier_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing data before running the test
DELETE FROM mamba_dim_patient_identifier;

-- Step 3: Call the sp_mamba_dim_patient_identifier_insert procedure
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert data into mamba_dim_patient_identifier table via sp_mamba_dim_patient_identifier_insert.';
            -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_patient_identifier_insert', 'FAILED', failed_message, NOW());
END;

        -- Call the stored procedure to insert test data
CALL sp_mamba_dim_patient_identifier_insert();
END;

    -- Step 4: Validate the insertion of data
    IF NOT EXISTS (SELECT * FROM mamba_dim_patient_identifier WHERE patient_identifier_id = 1) THEN
        SET test_failed = 1;
        SET failed_message = 'Data was not inserted into mamba_dim_patient_identifier table.';
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_patient_identifier_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 5: Check if the data inserted matches the expected values
    DECLARE actual_count INT;
SELECT COUNT(*) INTO actual_count
FROM mamba_dim_patient_identifier
WHERE patient_identifier_id = 1;

IF actual_count != 1 THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Expected 1 record but found ', actual_count);
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_patient_identifier_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 6: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
        -- Log the success message into _mamba_etl_test_log
        INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
        VALUES ('test_sp_mamba_dim_patient_identifier_insert', 'PASSED', 'Data inserted successfully into mamba_dim_patient_identifier table.', NOW());
SELECT 'Unit Test Passed: Data inserted successfully into mamba_dim_patient_identifier table.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_patient_identifier_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_patient_identifier_insert;


-- $END
