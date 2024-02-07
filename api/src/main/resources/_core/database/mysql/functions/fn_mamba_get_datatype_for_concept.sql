DROP FUNCTION IF EXISTS fn_mamba_get_datatype_for_concept;

DELIMITER //

CREATE FUNCTION fn_mamba_get_datatype_for_concept(conceptDatatype VARCHAR(20)) RETURNS VARCHAR(20)
    DETERMINISTIC
BEGIN
    DECLARE mysqlDatatype VARCHAR(20);

    CASE conceptDatatype
        WHEN conceptDatatype IN ('Coded','N/A','Text') THEN SET  mysqlDatatype = 'TEXT';
        WHEN conceptDatatype = 'Boolean' THEN SET mysqlDatatype = 'VARCHAR(50)';
        WHEN conceptDatatype = 'Date' THEN SET mysqlDatatype = 'DATE';
        WHEN conceptDatatype = 'Datetime' THEN  SET mysqlDatatype = 'DATETIME';
        WHEN conceptDatatype = 'Numeric' THEN SET  mysqlDatatype = 'DOUBLE';
    END CASE;

    RETURN mysqlDatatype;
END //

DELIMITER ;