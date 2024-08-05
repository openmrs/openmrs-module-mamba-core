DROP PROCEDURE IF EXISTS sp_mamba_truncate_table;

DELIMITER //

CREATE PROCEDURE sp_mamba_truncate_table(
    IN table_to_truncate VARCHAR(64) CHARACTER SET UTF8MB4
)
BEGIN
    IF EXISTS (SELECT 1
               FROM information_schema.tables
               WHERE table_schema = DATABASE()
                 AND table_name = table_to_truncate) THEN

        SET @sql = CONCAT('TRUNCATE TABLE ', table_to_truncate);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END IF;

END //

DELIMITER ;