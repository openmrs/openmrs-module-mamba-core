DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_insert;

DELIMITER //

CREATE PROCEDURE sp_mamba_flat_encounter_table_insert(
    IN flat_encounter_table_name VARCHAR(60) CHARACTER SET UTF8MB4
)
BEGIN

    SET session group_concat_max_len = 20000;
    SET @tbl_name = flat_encounter_table_name;

    -- Precompute the concept metadata table to minimize repeated queries
    CREATE TEMPORARY TABLE mamba_temp_concept_metadata
    (
        id                 INT          NOT NULL,
        flat_table_name    VARCHAR(60)  NOT NULL,
        column_label       VARCHAR(255) NOT NULL,
        obs_value_column   VARCHAR(50),
        concept_uuid       CHAR(38)     NOT NULL,
        concept_answer_obs INT,

        INDEX mamba_idx_id (id),
        INDEX mamba_idx_column_label (column_label),
        INDEX mamba_idx_concept_uuid (concept_uuid),
        INDEX mamba_idx_concept_answer_obs (concept_answer_obs),
        INDEX mamba_idx_flat_table_name (flat_table_name)
    )
        CHARSET = UTF8MB4;

    INSERT INTO mamba_temp_concept_metadata
    SELECT DISTINCT id,
                    flat_table_name,
                    column_label,
                    fn_mamba_get_obs_value_column(concept_datatype) AS obs_value_column,
                    concept_uuid,
                    concept_answer_obs
    FROM mamba_concept_metadata
    WHERE flat_table_name = @tbl_name
      AND concept_id IS NOT NULL
      AND concept_datatype IS NOT NULL;

    SELECT GROUP_CONCAT(DISTINCT
                        CONCAT('MAX(CASE WHEN column_label = ''', column_label, ''' THEN ',
                               obs_value_column, ' END) ', column_label)
                        ORDER BY id ASC)
    INTO @column_labels
    FROM mamba_temp_concept_metadata;

    IF @column_labels IS NOT NULL THEN
        -- First Insert: concept_answer_obs = 0
        SET @insert_stmt = CONCAT(
                'INSERT INTO `', @tbl_name,
                '` SELECT o.encounter_id, MAX(o.visit_id) AS visit_id, o.person_id, o.encounter_datetime, MAX(o.location_id) AS location_id, ',
                @column_labels, '
                FROM mamba_z_encounter_obs o
                    INNER JOIN mamba_temp_concept_metadata tcm
                    ON tcm.concept_uuid = o.obs_question_uuid
                WHERE tcm.flat_table_name = ''', @tbl_name, '''
                AND tcm.concept_answer_obs = 0
                AND tcm.obs_value_column IS NOT NULL
                AND o.obs_group_id IS NULL AND o.voided = 0
                GROUP BY o.encounter_id, o.person_id, o.encounter_datetime
                ORDER BY o.encounter_id ASC');

        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;

        -- Second Insert: concept_answer_obs = 1, Handle potential duplicates
        SET @update_stmt =
                (SELECT GROUP_CONCAT(CONCAT(column_label, ' = COALESCE(VALUES(', column_label, '), ', column_label,
                                            ')'))
                 FROM mamba_temp_concept_metadata);

        SET @insert_stmt = CONCAT(
                'INSERT INTO `', @tbl_name,
                '` SELECT o.encounter_id, MAX(o.visit_id) AS visit_id, o.person_id, o.encounter_datetime, MAX(o.location_id) AS location_id, ',
                @column_labels, '
                FROM mamba_z_encounter_obs o
                    INNER JOIN mamba_temp_concept_metadata tcm
                    ON tcm.concept_uuid = o.obs_value_coded_uuid
                WHERE tcm.flat_table_name = ''', @tbl_name, '''
                AND tcm.concept_answer_obs = 1
                AND tcm.obs_value_column IS NOT NULL
                AND o.obs_group_id IS NULL AND o.voided = 0
                GROUP BY o.encounter_id, o.person_id, o.encounter_datetime
                ORDER BY o.encounter_id ASC
                ON DUPLICATE KEY UPDATE ', @update_stmt);

        PREPARE inserttbl FROM @insert_stmt;
        EXECUTE inserttbl;
        DEALLOCATE PREPARE inserttbl;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS mamba_temp_concept_metadata;

END //

DELIMITER ;