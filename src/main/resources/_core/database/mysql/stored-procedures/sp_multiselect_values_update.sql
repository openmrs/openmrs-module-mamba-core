DELIMITER //

DROP PROCEDURE IF EXISTS `sp_multiselect_values_update`;

CREATE PROCEDURE `sp_multiselect_values_update`(
        IN table_to_update NVARCHAR(100),
        IN column_names NVARCHAR(20000),
        IN value_yes NVARCHAR(100),
        IN value_no NVARCHAR(100)
)
BEGIN

    SET @table_columns = column_names;
    SET @start_pos = 1;
    SET @comma_pos = locate(',', @table_columns);
    SET @end_loop = 0;

    SET @column_label = '';

    REPEAT
        IF @comma_pos > 0 THEN
            SET @column_label = substring(@table_columns, @start_pos, @comma_pos - @start_pos);
            SET @end_loop = 0;
        ELSE
            SET @column_label = substring(@table_columns, @start_pos);
            SET @end_loop = 1;
        END IF;

        -- UPDATE fact_hts SET @column_label=IF(@column_label IS NULL OR '', new_value_if_false, new_value_if_true);

         SET @update_sql = CONCAT(
             'UPDATE ', table_to_update ,' SET ', @column_label ,'= IF(', @column_label ,' IS NOT NULL, ''',value_yes,''', ''',value_no,''');');
        PREPARE stmt FROM @update_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        IF @end_loop = 0 THEN
            SET @table_columns = substring(@table_columns, @comma_pos + 1);
            SET @comma_pos = locate(',', @table_columns);
        END IF;
        UNTIL @end_loop = 1

    END REPEAT;

END //

DELIMITER ;


