DROP PROCEDURE IF EXISTS sp_mamba_etl_user_settings_insert_helper;

DELIMITER //

CREATE PROCEDURE sp_mamba_etl_user_settings_insert_helper(
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4,
    IN table_partition_number INT,
    IN incremental_mode_switch TINYINT(1)
)
BEGIN

    SET @conc_locale = concepts_locale;
    SET @table_partition = table_partition_number;
    SET @incremental_mode = incremental_mode_switch;
    SET @insert_stmt = CONCAT('INSERT INTO mamba_etl_user_settings (concepts_locale, table_partition_number, incremental_mode_switch) VALUES (',@conc_locale, ', ',@table_partition,', ',@incremental_mode,');');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END //

DELIMITER ;