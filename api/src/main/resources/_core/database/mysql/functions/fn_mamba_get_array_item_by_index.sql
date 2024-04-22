DROP FUNCTION IF EXISTS fn_mamba_get_array_item_by_index;
DELIMITER //

CREATE FUNCTION fn_mamba_get_array_item_by_index(array_string TEXT, item_index INT) RETURNS TEXT
    DETERMINISTIC
BEGIN
  DECLARE elem_start INT DEFAULT 1;
  DECLARE elem_end INT DEFAULT 0;
  DECLARE current_index INT DEFAULT 0;
  DECLARE result TEXT DEFAULT '';

    -- If the item_index is less than 1 or the array_string is empty, return an empty string
    IF item_index < 1 OR array_string = '[]' OR TRIM(array_string) = '' THEN
        RETURN '';
    END IF;

    -- Loop until we find the start quote of the desired index
    WHILE current_index < item_index DO
        -- Find the start quote of the next element
        SET elem_start = LOCATE('"', array_string, elem_end + 1);
        -- If we can't find a new element, return an empty string
        IF elem_start = 0 THEN
          RETURN '';
        END IF;

        -- Find the end quote of this element
        SET elem_end = LOCATE('"', array_string, elem_start + 1);
        -- If we can't find the end quote, return an empty string
        IF elem_end = 0 THEN
          RETURN '';
        END IF;

        -- Increment the current_index
        SET current_index = current_index + 1;
    END WHILE;

    -- When the loop exits, current_index should equal item_index, and elem_start/end should be the positions of the quotes
    -- Extract the element
    SET result = SUBSTRING(array_string, elem_start + 1, elem_end - elem_start - 1);

    RETURN result;
END //

DELIMITER ;