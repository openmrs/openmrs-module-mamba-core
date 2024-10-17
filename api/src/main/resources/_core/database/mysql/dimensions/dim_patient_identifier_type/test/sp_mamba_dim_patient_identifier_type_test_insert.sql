-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_patient_identifier_type_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_patient_identifier_type_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_patient_identifier_type_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing data before running the test
DELETE FROM mamba_dim_patient_identifier_type;

-- Step 3: Call the sp_mamba_dim_patient_identifier_type_insert procedure to insert data
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert records into mamba_dim_patient_identifier_type table via sp_mamba_dim_patient_identifier_type_insert.';
            -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_patient_identifier_type_insert', 'FAILED', failed_message, NOW());
END;

        -- Call the stored procedure to insert data
CALL sp_mamba_dim_patient_identifier_type_insert();
END;

    -- Step 4: Validate that data was inserted successfully
    IF (SELECT COUNT(*) FROM mamba_dim_patient_identifier_type) = 0 THEN
        SET test_failed = 1;
SET failed_message = 'No records were inserted into mamba_dim_patient_identifier_type by sp_mamba_dim_patient_identifier_type_insert.';
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_patient_identifier_type_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 5: Validate the inserted data
    DECLARE expected_count INT DEFAULT 3;
    DECLARE actual_count INT;

SELECT COUNT(*) INTO actual_count FROM mamba_dim_patient_identifier_type;

IF actual_count != expected_count THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Expected ', expected_count, ' records, found ', actual_count, '.');
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_patient_identifier_type_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 6: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
        -- Log the success message into _mamba_etl_test_log
        INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
        VALUES ('test_sp_mamba_dim_patient_identifier_type_insert', 'PASSED', 'Records inserted successfully into mamba_dim_patient_identifier_type.', NOW());
SELECT 'Unit Test Passed: Records inserted successfully into mamba_dim_patient_identifier_type.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_patient_identifier_type_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_patient_identifier_type_insert;


-- $END
