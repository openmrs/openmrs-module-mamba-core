-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing data before running the test
DELETE FROM mamba_dim_person;

-- Step 3: Call the sp_mamba_dim_person_insert procedure to insert a record
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert into mamba_dim_person table via sp_mamba_dim_person_insert.';
            -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_insert', 'FAILED', failed_message, NOW());
END;

        -- Call the stored procedure to insert the record
CALL sp_mamba_dim_person_insert();
END;

    -- Step 4: Validate that the record was inserted
    IF (SELECT COUNT(*) FROM mamba_dim_person) = 0 THEN
        SET test_failed = 1;
SET failed_message = 'No records were inserted into mamba_dim_person.';
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 5: Validate the inserted data
    DECLARE actual_record_count INT;
SELECT COUNT(*) INTO actual_record_count FROM mamba_dim_person WHERE person_id = 1;

IF actual_record_count != 1 THEN
        SET test_failed = 1;
        SET failed_message = 'Inserted record not found in mamba_dim_person.';
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_person_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 6: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
        -- Log the success message into _mamba_etl_test_log
        INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
        VALUES ('test_sp_mamba_dim_person_insert', 'PASSED', 'Record inserted successfully into mamba_dim_person.', NOW());
SELECT 'Unit Test Passed: Record inserted successfully into mamba_dim_person.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_insert;


-- $END
