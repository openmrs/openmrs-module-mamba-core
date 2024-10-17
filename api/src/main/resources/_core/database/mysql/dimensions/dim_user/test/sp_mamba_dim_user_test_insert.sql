-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_user_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_user_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_user_insert()
BEGIN
    DECLARE test_failed INT DEFAULT 0;
    DECLARE failed_message VARCHAR(255) DEFAULT '';

    -- Step 1: Call the stored procedure to insert a user
    CALL sp_mamba_dim_user_insert();

    -- Step 2: Check if the user was inserted successfully
    IF NOT EXISTS (SELECT * FROM mamba_dim_user WHERE user_id = LAST_INSERT_ID()) THEN
            SET test_failed = 1;
            SET failed_message = 'User insertion failed.';
    END IF;

    -- Step 3: Log the result into mamba_etl_test_log
    IF test_failed = 1 THEN
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES ('test_sp_mamba_dim_user_insert', CONCAT('Unit Test Failed: ', failed_message));
    ELSE
        INSERT INTO mamba_etl_test_log (test_name, log_message)
        VALUES ('test_sp_mamba_dim_user_insert', 'Unit Test Passed: User inserted successfully.');
    END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_user_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_user_insert;


-- $END
