-- $BEGIN
-- -------------------------------------------------------------------------------------
-- Unit Test for sp_mamba_dim_concept_answer_insert procedure
-- -------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_answer_insert;

DELIMITER //

CREATE PROCEDURE test_sp_mamba_dim_concept_answer_insert()
BEGIN
    -- Step 1: Variables for test results
    DECLARE failed_message VARCHAR(255) DEFAULT '';
    DECLARE test_failed INT DEFAULT 0;

    -- Step 2: Clean up any existing records before running the test
    DELETE FROM mamba_dim_concept_answer;

    -- Step 3: Prepare test data
    INSERT INTO mamba_dim_concept_answer (concept_answer_id, concept_id, answer_concept, answer_drug, incremental_record)
    VALUES
        (1, 101, 1001, 2001, 0),
        (2, 102, 1002, NULL, 0),
        (3, 103, NULL, 2003, 0);

    -- Step 4: Call the sp_mamba_dim_concept_answer_insert procedure to insert data
    BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
                SET test_failed = 1;
                SET failed_message = 'Failed to insert data into mamba_dim_concept_answer table via sp_mamba_dim_concept_answer_insert.';
    END;

    -- Call the stored procedure to insert data
    CALL sp_mamba_dim_concept_answer_insert();
    END;

    -- Step 5: Validate the data insertion
    DECLARE expected_count INT DEFAULT 3;
    DECLARE actual_count INT;

    SELECT COUNT(*) INTO actual_count FROM mamba_dim_concept_answer;

    IF actual_count != expected_count THEN
            SET test_failed = 1;
            SET failed_message = CONCAT('Data insertion failed. Expected row count: ', expected_count, ', Actual row count: ', actual_count);
    END IF;

    -- Step 6: Check if the inserted values match the expected values
    DECLARE actual_answer_concept INT;
    DECLARE actual_answer_drug INT;

    SELECT answer_concept, answer_drug INTO actual_answer_concept, actual_answer_drug
    FROM mamba_dim_concept_answer
    WHERE concept_answer_id = 1;

    IF actual_answer_concept != 1001 OR actual_answer_drug != 2001 THEN
        SET test_failed = 1;
        SET failed_message = 'Inserted values do not match expected values for concept_answer_id = 1.';
    END IF;

        -- Step 7: Return result
    IF test_failed = 1 THEN
        SELECT CONCAT('Unit Test Failed: ', failed_message) AS result;
    ELSE
        SELECT 'Unit Test Passed: Data inserted successfully into mamba_dim_concept_answer via sp_mamba_dim_concept_answer_insert.' AS result;
    END IF;
END //

DELIMITER ;

-- Run the unit test
CALL test_sp_mamba_dim_concept_answer_insert();

-- Clean up after the test
DROP PROCEDURE IF EXISTS test_sp_mamba_dim_concept_answer_insert;

-- $END