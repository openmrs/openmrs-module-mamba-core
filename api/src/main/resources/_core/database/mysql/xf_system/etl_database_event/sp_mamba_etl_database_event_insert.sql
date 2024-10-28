DROP PROCEDURE IF EXISTS sp_mamba_etl_database_event_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_database_event_insert(
    IN incremental_table_pkey INT,
    IN table_name VARCHAR(100),
    IN database_operation ENUM ('CREATE', 'UPDATE', 'DELETE')
)
BEGIN
    START TRANSACTION;

    INSERT INTO _mamba_etl_database_event (incremental_table_pkey, table_name, database_operation)
    VALUES (incremental_table_pkey, table_name, database_operation);
    COMMIT;

END //

DELIMITER ;