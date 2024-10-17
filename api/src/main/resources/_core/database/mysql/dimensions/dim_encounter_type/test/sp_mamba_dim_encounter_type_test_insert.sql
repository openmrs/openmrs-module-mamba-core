-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_encounter_type_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_encounter_type_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_encounter_type_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up existing table data
DELETE FROM mamba_dim_encounter_type;

-- Step 3: Insert test data into the source table
INSERT INTO openmrs.encounter_type (encounter_type_id, name, description, uuid, date_created, retired)
VALUES
    (1, 'Consultation', 'Patient consultation encounter', 'uuid-001', NOW(), 0),
    (2, 'Surgery', 'Surgical encounter', 'uuid-002', NOW(), 0),
    (3, 'Lab Test', 'Laboratory test encounter', 'uuid-003', NOW(), 0);

-- Step 4: Call the sp_mamba_dim_encounter_type_insert procedure
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Error occurred during sp_mamba_dim_encounter_type_insert execution.';
END;

        -- Call the stored procedure to insert data
CALL sp_mamba_dim_encounter_type_insert();
END;

    -- Step 5: Validate the data was inserted correctly into mamba_dim_encounter_type
    DECLARE inserted_count INT;
SELECT COUNT(*) INTO inserted_count FROM mamba_dim_encounter_type;

IF inserted_count != 3 THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Expected 3 rows in mamba_dim_encounter_type, but found ', inserted_count);
END IF;

    -- Step 6: Return the test result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
SELECT 'Unit Test Passed: Data inserted successfully into mamba_dim_encounter_type via sp_mamba_dim_encounter_type_insert.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_encounter_type_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_encounter_type_insert;

-- $END
