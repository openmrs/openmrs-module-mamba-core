DROP PROCEDURE IF EXISTS sp_mamba_etl_user_settings;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_user_settings(
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4,
    IN table_partition_number INT,
    IN incremental_mode_switch TINYINT(1),
    IN automatic_flattening_mode_switch TINYINT(1),
    IN etl_interval_seconds INT
)
BEGIN

    DECLARE locale CHAR(4) DEFAULT IFNULL(concepts_locale, 'en');
    DECLARE column_number INT DEFAULT IFNULL(table_partition_number, 50);
    DECLARE is_incremental TINYINT(1) DEFAULT IFNULL(incremental_mode_switch, 1);
    DECLARE is_automatic_flattening TINYINT(1) DEFAULT IFNULL(automatic_flattening_mode_switch, 1);
    DECLARE etl_interval INT DEFAULT IFNULL(etl_interval_seconds, 60);

    CALL sp_mamba_etl_user_settings_drop();
    CALL sp_mamba_etl_user_settings_create();
    CALL sp_mamba_etl_user_settings_insert(locale,
                                           column_number,
                                           is_incremental,
                                           is_automatic_flattening,
                                           etl_interval);

END //

DELIMITER ;