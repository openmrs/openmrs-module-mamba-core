DROP PROCEDURE IF EXISTS sp_mamba_etl_user_settings_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_user_settings_insert(
    IN openmrs_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN etl_database VARCHAR(256) CHARACTER SET UTF8MB4,
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4,
    IN table_partition_number INT,
    IN incremental_mode_switch TINYINT(1),
    IN automatic_flattening_mode_switch TINYINT(1),
    IN etl_interval_seconds INT
)
BEGIN

    SET @insert_stmt = CONCAT(
            'INSERT INTO _mamba_etl_user_settings (`openmrs_database`, `etl_database`, `concepts_locale`, `table_partition_number`, `incremental_mode_switch`, `automatic_flattening_mode_switch`, `etl_interval_seconds`) VALUES (''',
            openmrs_database, ''', ''', etl_database, ''', ''', concepts_locale, ''', ', table_partition_number, ', ', incremental_mode_switch, ', ', automatic_flattening_mode_switch, ', ', etl_interval_seconds, ');');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END //

DELIMITER ;