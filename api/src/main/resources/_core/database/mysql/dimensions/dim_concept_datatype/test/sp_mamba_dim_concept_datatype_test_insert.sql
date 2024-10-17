-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_concept_datatype_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_datatype_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_concept_datatype_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing data before running the test
    DELETE FROM mamba_dim_concept_datatype; -- Clean up target table

    -- Step 3: Call the sp_mamba_dim_concept_datatype_insert procedure to insert data
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert data into mamba_dim_concept_datatype via sp_mamba_dim_concept_datatype_insert.';
        END;

            -- Call the stored procedure to insert data
        CALL sp_mamba_dim_concept_datatype_insert();
    END;

        -- Step 4: Validate if data was inserted into the table
    IF (SELECT COUNT(*) FROM mamba_dim_concept_datatype) = 0 THEN
            SET test_failed = 1;
        SET failed_message = 'No data was inserted into mamba_dim_concept_datatype by sp_mamba_dim_concept_datatype_insert.';
    END IF;

        -- Step 5: Optionally, you can validate specific data inserted, for example:
    IF NOT EXISTS (SELECT 1 FROM mamba_dim_concept_datatype WHERE name = 'Numeric' AND description = 'Numeric data type') THEN
        SET test_failed = 1;
        SET failed_message = 'Expected data not found in mamba_dim_concept_datatype after sp_mamba_dim_concept_datatype_insert.';
    END IF;

        -- Step 6: Return result
    IF test_failed = 1 THEN
        SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
    ELSE
        SELECT 'Unit Test Passed: Data inserted successfully into mamba_dim_concept_datatype via sp_mamba_dim_concept_datatype_insert.' AS result;
    END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_concept_datatype_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_datatype_insert;

-- $END