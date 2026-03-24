DROP PROCEDURE IF EXISTS sp_mamba_flat_encounter_table_question_concepts_insert;

DELIMITER //

-- SP inserts all concepts that are questions or have a concept_id value in the Obs table
-- whether their values/answers are coded or non-coded
CREATE PROCEDURE sp_mamba_flat_encounter_table_question_concepts_insert(
 IN p_table_name VARCHAR(60),
 IN p_encounter_id INT,
 IN p_encounter_type_uuid CHAR(38),
 IN p_column_labels TEXT
)
BEGIN
 DECLARE sql_stmt TEXT;
 DECLARE batch_size INT DEFAULT 100000; -- 100K batch size
 DECLARE min_encounter_id INT;
 DECLARE max_encounter_id INT;
 DECLARE current_id INT;

 IF p_encounter_id IS NOT NULL THEN
     -- Single encounter insert (Incremental)
     SET sql_stmt = CONCAT(
     'INSERT INTO `', p_table_name, '` ',
     'SELECT
     o.encounter_id,
     MAX(o.visit_id) AS visit_id,
     MAX(o.person_id) AS person_id,
     MAX(o.encounter_datetime) AS encounter_datetime,
     MAX(o.location_id) AS location_id,
     ', p_column_labels, '
     FROM mamba_z_encounter_obs o
     INNER JOIN temp_concept_metadata tcm
     ON tcm.concept_uuid = o.obs_question_uuid
     WHERE o.encounter_id = ', p_encounter_id, '
     AND o.encounter_type_uuid = ''', p_encounter_type_uuid, '''
     AND tcm.obs_value_column IS NOT NULL
     AND o.obs_group_id IS NULL
     AND o.voided = 0
     GROUP BY o.encounter_id
     ORDER BY o.encounter_id ASC');

     SET @sql = sql_stmt;
     PREPARE stmt FROM @sql;
     EXECUTE stmt;
     DEALLOCATE PREPARE stmt;

 ELSE
     -- Batched execution for full load
     SELECT MIN(encounter_id), MAX(encounter_id) 
     INTO min_encounter_id, max_encounter_id 
     FROM mamba_z_encounter_obs;

     SET current_id = COALESCE(min_encounter_id, 0);
     SET max_encounter_id = COALESCE(max_encounter_id, 0);

     WHILE current_id <= max_encounter_id DO
         SET sql_stmt = CONCAT(
         'INSERT INTO `', p_table_name, '` ',
         'SELECT
         o.encounter_id,
         MAX(o.visit_id) AS visit_id,
         MAX(o.person_id) AS person_id,
         MAX(o.encounter_datetime) AS encounter_datetime,
         MAX(o.location_id) AS location_id,
         ', p_column_labels, '
         FROM mamba_z_encounter_obs o
         INNER JOIN temp_concept_metadata tcm
         ON tcm.concept_uuid = o.obs_question_uuid
         WHERE o.encounter_id >= ', current_id, ' 
           AND o.encounter_id < ', current_id + batch_size, '
           AND o.encounter_type_uuid = ''', p_encounter_type_uuid, '''
           AND tcm.obs_value_column IS NOT NULL
           AND o.obs_group_id IS NULL
           AND o.voided = 0
         GROUP BY o.encounter_id
         ORDER BY o.encounter_id ASC');

         SET @sql = sql_stmt;
         PREPARE stmt FROM @sql;
         EXECUTE stmt;
         DEALLOCATE PREPARE stmt;

         SET current_id = current_id + batch_size;
     END WHILE;

 END IF;

END //

DELIMITER ;
