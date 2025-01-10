DROP PROCEDURE IF EXISTS sp_mamba_locale_insert_helper;

DELIMITER //

CREATE PROCEDURE sp_mamba_locale_insert_helper(
    IN concepts_locale CHAR(4) CHARACTER SET UTF8MB4 COLLATE utf8mb4_general_ci
)
BEGIN

    SET @conc_locale = concepts_locale;
    SET @insert_stmt = CONCAT('INSERT INTO mamba_dim_locale (locale) VALUES (''', @conc_locale, ''');');

    PREPARE inserttbl FROM @insert_stmt;
    EXECUTE inserttbl;
    DEALLOCATE PREPARE inserttbl;

END //

DELIMITER ;