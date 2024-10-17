-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_user_create procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_user_create;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_user_create()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Drop the table if it already exists to ensure a clean state
    DROP TABLE IF EXISTS mamba_dim_user;

    -- Step 3: Call the sp_mamba_dim_user_create procedure
    BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to create mamba_dim_user table.';
        END;

        -- Call the stored procedure to create the user table
        CALL sp_mamba_dim_user_create();
    END;

    -- Step 4: Validate that the table was created successfully
    IF NOT EXISTS (SELECT * FROM information_schema.tables
                   WHERE table_name = 'mamba_dim_user') THEN
        SET test_failed = 1;
        SET failed_message = 'mamba_dim_user table not found after creation.';
    END IF;

    -- Step 5: Log the result
    IF test_failed = 1 THEN
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES ('test_sp_mamba_dim_user_create', CONCAT('Unit Test Failed: ', failed_message));
    ELSE
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES ('test_sp_mamba_dim_user_create', 'Unit Test Passed: mamba_dim_user table created successfully.');
    END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_user_create();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_user_create;


-- $END
