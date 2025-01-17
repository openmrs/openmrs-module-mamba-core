DROP PROCEDURE IF EXISTS sp_mamba_write_automated_json_config;

DELIMITER //

CREATE PROCEDURE sp_mamba_write_automated_json_config()
BEGIN

    DECLARE done INT DEFAULT FALSE;
    DECLARE jsonData JSON;
    DECLARE cur CURSOR FOR
        SELECT table_json_data FROM mamba_flat_table_config;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        SET @report_data = '{"flat_report_metadata":[';

        OPEN cur;
        FETCH cur INTO jsonData;

        IF NOT done THEN
                    SET @report_data = CONCAT(@report_data, jsonData);
        FETCH cur INTO jsonData; -- Fetch next record after the first one
        END IF;

                read_loop: LOOP
                    IF done THEN
                        LEAVE read_loop;
        END IF;

                    SET @report_data = CONCAT(@report_data, ',', jsonData);
        FETCH cur INTO jsonData;
        END LOOP;
        CLOSE cur;

        SET @report_data = CONCAT(@report_data, ']}');

        CALL sp_mamba_extract_report_metadata(@report_data, 'mamba_concept_metadata');

END //

DELIMITER ;