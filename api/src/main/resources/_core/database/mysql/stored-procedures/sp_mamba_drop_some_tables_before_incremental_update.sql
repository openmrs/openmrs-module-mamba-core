DROP PROCEDURE IF EXISTS sp_mamba_drop_some_tables_before_incremental_update;

DELIMITER //

CREATE PROCEDURE sp_mamba_drop_some_tables_before_incremental_update()
BEGIN

    DROP TABLE IF EXISTS mamba_dim_json_incremental;
    DROP TABLE IF EXISTS mamba_dim_concept_metadata;
    DROP TABLE IF EXISTS mamba_etl_user_settings;

END //

DELIMITER ;