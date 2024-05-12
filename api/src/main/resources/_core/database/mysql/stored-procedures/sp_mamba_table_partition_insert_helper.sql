DROP PROCEDURE IF EXISTS sp_mamba_table_partition_insert_helper;

DELIMITER //

CREATE PROCEDURE sp_mamba_table_partition_insert_helper(
    IN table_partition_number CHAR(4) CHARACTER SET UTF8MB4
)
BEGIN

    SET @table_partition = table_partition_number;
    SET @insert_stmt = CONCAT('INSERT INTO mamba_dim_table_partition (table_partition_number) VALUES (''', @table_partition, ''');');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END //

DELIMITER ;