DROP FUNCTION IF EXISTS fn_mamba_is_mysql8_or_higher;

DELIMITER //

CREATE FUNCTION fn_mamba_is_mysql8_or_higher()
    RETURNS BOOLEAN
    DETERMINISTIC
    READS SQL DATA
    COMMENT 'Returns TRUE if MySQL version is 8.0 or higher, FALSE otherwise'
    
BEGIN
    DECLARE mysql_version VARCHAR(20);

    -- Get MySQL major version number
    SET mysql_version = SUBSTRING_INDEX(VERSION(), '.', 1);

    -- Return TRUE if version is 8 or higher
    RETURN CAST(mysql_version AS UNSIGNED) >= 8;
END //

DELIMITER ; 