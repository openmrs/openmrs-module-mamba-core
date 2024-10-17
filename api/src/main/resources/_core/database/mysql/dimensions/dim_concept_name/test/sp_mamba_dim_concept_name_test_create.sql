-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_concept_name_create
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_name_create;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_concept_name_create()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up pre-existing table if it exists
    IF (EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'mamba_dim_concept_name' AND table_schema = DATABASE())) THEN
        DROP TABLE mamba_dim_concept_name;
    END IF;

        -- Step 3: Call the procedure to be tested
    BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
                SET test_failed = 1;
                SET failed_message = 'Procedure failed to create the table.';
        END;

            -- Call the procedure to create the table
        CALL sp_mamba_dim_concept_name_create();
    END;

    -- Step 4: Validate the creation of the table
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'mamba_dim_concept_name' AND table_schema = DATABASE()) THEN
        SET test_failed = 1;
        SET failed_message = 'Table mamba_dim_concept_name was not created.';
    END IF;

    -- Step 5: Check column definitions
    IF NOT EXISTS (SELECT * FROM information_schema.columns
                   WHERE table_name = 'mamba_dim_concept_name' AND column_name = 'concept_name_id' AND data_type = 'int') THEN
        SET test_failed = 1;
        SET failed_message = 'Column concept_name_id is not defined as INT.';
    END IF;

    IF NOT EXISTS (SELECT * FROM information_schema.columns
                   WHERE table_name = 'mamba_dim_concept_name' AND column_name = 'name' AND data_type = 'varchar' AND character_maximum_length = 255) THEN
        SET test_failed = 1;
        SET failed_message = 'Column name is not defined as VARCHAR(255).';
    END IF;

    IF NOT EXISTS (SELECT * FROM information_schema.columns
                   WHERE table_name = 'mamba_dim_concept_name' AND column_name = 'locale' AND data_type = 'varchar' AND character_maximum_length = 50) THEN
        SET test_failed = 1;
        SET failed_message = 'Column locale is not defined as VARCHAR(50).';
    END IF;

    -- Step 6: Check for existence of indexes
    IF NOT EXISTS (SELECT * FROM information_schema.statistics WHERE table_name = 'mamba_dim_concept_name' AND index_name = 'mamba_idx_concept_id') THEN
        SET test_failed = 1;
        SET failed_message = 'Index mamba_idx_concept_id is missing.';
    END IF;

    -- Step 7: Return result
    IF test_failed = 1 THEN
        SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
    ELSE
        SELECT 'Unit Test Passed: sp_mamba_dim_concept_name_create executed successfully.' AS result;
    END IF;

    END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_concept_name_create();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_name_create;

-- $END