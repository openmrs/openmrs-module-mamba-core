DROP PROCEDURE IF EXISTS sp_mamba_etl_setup;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_setup(
    IN openmrs_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN etl_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4,
    IN table_partition_number INT,
    IN incremental_mode_switch TINYINT(1),
    IN automatic_flattening_mode_switch TINYINT(1),
    IN etl_interval_seconds INT,
    IN database_vendor VARCHAR(256) CHARACTER SET UTF8MB4
)
BEGIN

    -- Setup ETL Error log Table
    CALL sp_mamba_etl_error_log();

    -- Setup ETL configurations
    CALL sp_mamba_etl_user_settings(openmrs_database,
                                    etl_database,
                                    concepts_locale,
                                    table_partition_number,
                                    incremental_mode_switch,
                                    automatic_flattening_mode_switch,
                                    etl_interval_seconds);

    -- create ETL schedule log table
    CALL sp_mamba_etl_schedule_table_create();

END //

DELIMITER ;