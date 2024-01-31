DROP FUNCTION IF EXISTS fn_mamba_get_datatype_for_concept;

DELIMITER //

CREATE FUNCTION fn_mamba_get_datatype_for_concept(conceptDatatype VARCHAR(20)) RETURNS VARCHAR(20)
    DETERMINISTIC
BEGIN
    DECLARE mysqlDatatype VARCHAR(20);

    CASE conceptDatatype
        WHEN conceptDatatype = 'Coded' THEN  mysqlDatatype = 'TEXT';
        WHEN conceptDatatype = 'N/A' THEN  mysqlDatatype = 'TEXT';
        WHEN conceptDatatype = 'Text' THEN  mysqlDatatype = 'TEXT';
        WHEN conceptDatatype = 'Boolean' THEN  mysqlDatatype = 'VARCHAR(50)';
        WHEN conceptDatatype = 'Date' THEN  mysqlDatatype = 'DATE';
        WHEN conceptDatatype = 'Datetime' THEN  mysqlDatatype = 'DATETIME';
        WHEN conceptDatatype = 'Numeric' THEN  mysqlDatatype = 'DOUBLE';
    END CASE;

    RETURN mysqlDatatype;
END //

DELIMITER ;