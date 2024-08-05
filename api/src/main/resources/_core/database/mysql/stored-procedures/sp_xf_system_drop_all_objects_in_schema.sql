DROP PROCEDURE IF EXISTS sp_xf_system_drop_all_objects_in_schema;

DELIMITER //

CREATE PROCEDURE sp_xf_system_drop_all_objects_in_schema(
    IN database_name CHAR(255) CHARACTER SET UTF8MB4
)
BEGIN

    CALL sp_xf_system_drop_all_stored_functions_in_schema(database_name);
    CALL sp_xf_system_drop_all_stored_procedures_in_schema(database_name);
    CALL sp_mamba_system_drop_all_tables(database_name);
    # CALL sp_xf_system_drop_all_views_in_schema (database_name);

END //

DELIMITER ;
