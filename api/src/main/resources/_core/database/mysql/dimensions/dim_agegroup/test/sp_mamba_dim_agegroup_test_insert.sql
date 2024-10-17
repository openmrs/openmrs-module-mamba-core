-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_agegroup_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_agegroup_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_agegroup_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE test_failed INT DEFAULT 0;
    DECLARE failed_message VARCHAR(255) DEFAULT '';

    -- Step 2: Clean up existing data in the table before running the test
    DELETE FROM mamba_dim_agegroup;

    -- Step 3: Insert test data into the source table (if necessary)
    -- Assuming the source table has already existing data and no new data is inserted here
    -- (If source data needs setup, do it here by inserting test data)

    -- Step 4: Call the sp_mamba_dim_agegroup_insert procedure to insert the data
    BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
                SET test_failed = 1;
                SET failed_message = 'Failed to insert data into mamba_dim_agegroup via sp_mamba_dim_agegroup_insert.';
        END;

            -- Call the stored procedure to insert data
        CALL sp_mamba_dim_agegroup_insert();
    END;

        -- Step 5: Validate that data has been inserted into the mamba_dim_agegroup table
        DECLARE row_count INT;

    SELECT COUNT(*) INTO row_count FROM mamba_dim_agegroup;

    -- Check if data has been inserted
    IF row_count = 0 THEN
            SET test_failed = 1;
            SET failed_message = 'No data was inserted into the mamba_dim_agegroup table.';
    END IF;

        -- Step 6: Optionally, validate some specific values in the inserted rows (e.g., check a specific age group)
        DECLARE test_agegroup VARCHAR(50);
    SELECT datim_agegroup INTO test_agegroup FROM mamba_dim_agegroup LIMIT 1;

    IF test_agegroup IS NULL THEN
            SET test_failed = 1;
            SET failed_message = 'Data in mamba_dim_agegroup is not as expected.';
    END IF;

        -- Step 7: Return result
    IF test_failed = 1 THEN
        SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
    ELSE
        SELECT 'Unit Test Passed: Data successfully inserted into mamba_dim_agegroup via sp_mamba_dim_agegroup_insert.' AS result;
    END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_agegroup_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_agegroup_insert;


-- $END