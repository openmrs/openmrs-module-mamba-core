-- Given a table name, this procedure will reset the incremental_record column to 0 for all rows where the incremental_record is 1.
-- This is useful when we want to re-run the incremental updates for a table.

DROP PROCEDURE IF EXISTS sp_mamba_reset_incremental_update_flag;

DELIMITER //

CREATE PROCEDURE sp_mamba_reset_incremental_update_flag(
    IN table_name VARCHAR(60) CHARACTER SET UTF8MB4
)
BEGIN

    SET @tbl_name = table_name;

    SET @update_stmt =
            CONCAT('UPDATE ', @tbl_name, ' SET incremental_record = 0 WHERE incremental_record = 1');
    PREPARE updatetb FROM @update_stmt;
    EXECUTE updatetb;
    DEALLOCATE PREPARE updatetb;

END //

DELIMITER ;