-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_person_name_insert procedure (with logging)
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_name_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_person_name_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;
    DECLARE test_name VARCHAR(255) DEFAULT 'test_sp_mamba_dim_person_name_insert';

    -- Step 2: Clean up any existing data in the mamba_dim_person_name table before running the test
DELETE FROM mamba_dim_person_name;

-- Step 3: Call the sp_mamba_dim_person_name_insert procedure to insert data
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert data into mamba_dim_person_name table via sp_mamba_dim_person_name_insert.';
END;

        -- Call the stored procedure to insert sample data
CALL sp_mamba_dim_person_name_insert();
END;

    -- Step 4: Validate the data insertion
    IF NOT EXISTS (SELECT * FROM mamba_dim_person_name WHERE person_name_id = 1) THEN
        SET test_failed = 1;
        SET failed_message = 'Record with person_name_id = 1 was not inserted by sp_mamba_dim_person_name_insert.';
END IF;

    -- Step 5: Validate the inserted data
    DECLARE expected_full_name VARCHAR(255) DEFAULT 'John Paul Doe';
    DECLARE actual_full_name VARCHAR(255);

SELECT full_name INTO actual_full_name FROM mamba_dim_person_name WHERE person_name_id = 1;

-- Check if the actual full_name matches the expected full_name
IF actual_full_name != expected_full_name THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Inserted data mismatch. Expected: ', expected_full_name, ', Found: ', actual_full_name);
END IF;

    -- Step 6: Log the result
    IF test_failed = 1 THEN
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES (test_name, CONCAT('Unit Test Failed: ', failed_message));
ELSE
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES (test_name, 'Unit Test Passed: Data inserted successfully via sp_mamba_dim_person_name_insert with correct values.');
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_person_name_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_person_name_insert;


-- $END
