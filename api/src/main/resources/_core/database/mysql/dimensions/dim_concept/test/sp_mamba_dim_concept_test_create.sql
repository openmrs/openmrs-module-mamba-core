-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_concept_create
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_create;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_concept_create()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing table before running the test
    DROP TABLE IF EXISTS mamba_dim_concept;

    -- Step 3: Execute the procedure to be tested
    BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
                SET test_failed = 1;
                SET failed_message = 'Procedure sp_mamba_dim_concept_create failed to execute.';
    END;

            -- Call the procedure to create the table
    CALL sp_mamba_dim_concept_create();
    END;

        -- Step 4: Validate the creation of the table
        IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'mamba_dim_concept') THEN
            SET test_failed = 1;
            SET failed_message = 'Table mamba_dim_concept was not created.';
    END IF;

        -- Step 5: Validate the structure of the created table
        DECLARE expected_columns VARCHAR(255) DEFAULT 'concept_id, name, description, date_created, date_retired, retired, retire_reason, retired_by, incremental_record';
        DECLARE actual_columns VARCHAR(255);

    SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION) INTO actual_columns
    FROM information_schema.columns
    WHERE table_name = 'mamba_dim_concept';

    -- Check if the actual columns match expected columns
    IF actual_columns != expected_columns THEN
            SET test_failed = 1;
            SET failed_message = CONCAT('Table structure does not match. Expected: ', expected_columns, ' Found: ', actual_columns);
    END IF;

        -- Step 6: Return result
        IF test_failed = 1 THEN
    SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
    ELSE
    SELECT 'Unit Test Passed: sp_mamba_dim_concept_create executed successfully and table created.' AS result;
    END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_concept_create();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_create;
