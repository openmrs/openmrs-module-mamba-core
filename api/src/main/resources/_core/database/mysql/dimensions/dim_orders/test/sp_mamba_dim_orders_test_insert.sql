-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_orders_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_orders_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_orders_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Prepare the test environment
    -- Clean up any existing data in mamba_dim_orders
DELETE FROM mamba_dim_orders;

-- Ensure the table is created before insertion
CALL sp_mamba_dim_orders_create();

-- Step 3: Insert sample data into the source table (replace with actual source table name)
INSERT INTO source_orders_table (order_id, uuid, order_type_id, concept_id, patient_id, encounter_id,
                                 accession_number, order_number, orderer, instructions, date_activated,
                                 auto_expire_date, date_stopped, order_reason, order_reason_non_coded,
                                 urgency, previous_order_id, order_action, comment_to_fulfiller,
                                 care_setting, scheduled_date, order_group_id, sort_weight,
                                 fulfiller_comment, fulfiller_status, date_created, creator,
                                 voided, voided_by, date_voided, void_reason)
VALUES
    (1, 'UUID-001', 10, 100, 101, 201, 'ACC-001', 'ORD-001', 301, 'Instructions 1', '2024-10-01',
     NULL, NULL, NULL, NULL, 'Routine', NULL, 'Order Action 1', NULL,
     401, NULL, NULL, NULL, NULL, 'Fulfiller Status 1', '2024-10-01', 501,
     0, NULL, NULL, NULL),
    (2, 'UUID-002', 20, 200, 102, 202, 'ACC-002', 'ORD-002', 302, 'Instructions 2', '2024-10-02',
     NULL, NULL, NULL, NULL, 'Urgent', NULL, 'Order Action 2', NULL,
     402, NULL, NULL, NULL, NULL, 'Fulfiller Status 2', '2024-10-02', 502,
     0, NULL, NULL, NULL);

-- Step 4: Call the sp_mamba_dim_orders_insert procedure to insert data
BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
            SET test_failed = 1;
            SET failed_message = 'Failed to insert data into mamba_dim_orders via sp_mamba_dim_orders_insert.';
            -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_orders_insert', 'FAILED', failed_message, NOW());
END;

        -- Call the stored procedure to insert data
CALL sp_mamba_dim_orders_insert();
END;

    -- Step 5: Validate the data insertion
    DECLARE expected_count INT DEFAULT 2;
    DECLARE actual_count INT;

SELECT COUNT(*) INTO actual_count FROM mamba_dim_orders;

-- Check if the actual count matches the expected count
IF actual_count != expected_count THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Data insertion failed. Expected: ', expected_count, ' Found: ', actual_count);
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_orders_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 6: Validate the inserted data
    DECLARE check_order_id INT DEFAULT 1;
    DECLARE expected_urgency VARCHAR(50) DEFAULT 'Routine';

    DECLARE actual_urgency VARCHAR(50);
SELECT urgency INTO actual_urgency
FROM mamba_dim_orders
WHERE order_id = check_order_id;

IF actual_urgency != expected_urgency THEN
        SET test_failed = 1;
        SET failed_message = CONCAT('Data validation failed for order_id ', check_order_id, '. Expected urgency: ', expected_urgency, ', Found: ', actual_urgency);
        -- Log the failure message into _mamba_etl_test_log
INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
VALUES ('test_sp_mamba_dim_orders_insert', 'FAILED', failed_message, NOW());
END IF;

    -- Step 7: Return result
    IF test_failed = 1 THEN
SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
ELSE
        -- Log the success message into _mamba_etl_test_log
        INSERT INTO _mamba_etl_test_log (test_name, status, message, created_at)
        VALUES ('test_sp_mamba_dim_orders_insert', 'PASSED', 'Data inserted successfully into mamba_dim_orders via sp_mamba_dim_orders_insert.', NOW());
SELECT 'Unit Test Passed: Data inserted successfully into mamba_dim_orders via sp_mamba_dim_orders_insert.' AS result;
END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_orders_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_orders_insert;


-- $END
