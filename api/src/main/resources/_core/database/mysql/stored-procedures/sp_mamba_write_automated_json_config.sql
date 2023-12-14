DROP PROCEDURE IF EXISTS sp_mamba_write_automated_json_config;

DELIMITER //

CREATE PROCEDURE sp_mamba_write_automated_json_config()
BEGIN

    DECLARE countRows INT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE jsonData LONGTEXT;
    DECLARE cur CURSOR FOR
        SELECT json_data FROM mamba_dim_json;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT COUNT(*) INTO countRows FROM mamba_dim_concept_metadata;
    IF countRows = 0 THEN

        SET @report_data = '{"flat_report_metadata":[';
        OPEN cur;
        read_loop: LOOP
            FETCH cur INTO jsonData;

            IF done THEN
                LEAVE read_loop;
            END IF;

            SET @report_data = CONCAT(@report_data, jsonData, ',');

        END LOOP;
        CLOSE cur;

        -- Removing the trailing comma if present
        IF RIGHT(@report_data, 1) = ',' THEN
                SET @report_data = LEFT(@report_data, LENGTH(@report_data) - 1);
        END IF;
        SET @report_data = CONCAT(@report_data, ']}');

        CALL sp_mamba_extract_report_metadata(@report_data, 'mamba_dim_concept_metadata');

    ELSE
        SELECT 'mamba_dim_concept_metadata is not empty, no data copied.';
    END IF;

END //

DELIMITER ;