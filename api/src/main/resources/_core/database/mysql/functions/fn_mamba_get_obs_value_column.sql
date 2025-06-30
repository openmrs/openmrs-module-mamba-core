DROP FUNCTION IF EXISTS fn_mamba_get_obs_value_column;

DELIMITER //

CREATE FUNCTION fn_mamba_get_obs_value_column(conceptDatatype VARCHAR(20))
    RETURNS VARCHAR(20)
    DETERMINISTIC
    NO SQL
    COMMENT 'Determines the appropriate obs value column based on concept datatype. Returns column name as: obs_value_text, obs_value_boolean, obs_value_datetime, or obs_value_numeric.'

BEGIN
    DECLARE obsValueColumn VARCHAR(20);

    CASE LOWER(conceptDatatype)

        WHEN 'text' THEN SET obsValueColumn = 'obs_value_text'; -- Free text values

        WHEN 'coded' THEN SET obsValueColumn = 'obs_value_text'; -- Coded concept IDs stored as text

        WHEN 'n/a' THEN SET obsValueColumn = 'obs_value_text'; -- Handle unspecified/not-applicable types

        WHEN 'boolean' THEN SET obsValueColumn = 'obs_value_boolean'; -- True/false values

        WHEN 'date' THEN SET obsValueColumn = 'obs_value_datetime'; -- Date/datetime values

        WHEN 'datetime' THEN SET obsValueColumn = 'obs_value_datetime'; -- Explicit datetime handling

        WHEN 'numeric' THEN SET obsValueColumn = 'obs_value_numeric'; -- Numeric measurements

        ELSE SET obsValueColumn = 'obs_value_text';
        END CASE;

    RETURN (obsValueColumn);
END //

DELIMITER ;