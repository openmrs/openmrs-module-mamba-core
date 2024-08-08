-- $BEGIN

-- Update the hash of the JSON data
UPDATE mamba_flat_table_config_incremental
SET table_json_data_hash = MD5(TRIM(table_json_data))
WHERE id > 0;

-- If a new encounter type has been added
INSERT INTO mamba_flat_table_config (report_name,
                                     encounter_type_id,
                                     table_json_data,
                                     encounter_type_uuid,
                                     table_json_data_hash,
                                     incremental_record)
SELECT tci.report_name,
       tci.encounter_type_id,
       tci.table_json_data,
       tci.encounter_type_uuid,
       tci.table_json_data_hash,
       1
FROM mamba_flat_table_config_incremental tci
WHERE tci.encounter_type_id NOT IN (SELECT encounter_type_id FROM mamba_flat_table_config);

-- If there is any change in either concepts or encounter types in terms of names or additional questions
UPDATE mamba_flat_table_config tc
    INNER JOIN mamba_flat_table_config_incremental tci ON tc.encounter_type_id = tci.encounter_type_id
SET tc.table_json_data      = tci.table_json_data,
    tc.table_json_data_hash = tci.table_json_data_hash,
    tc.report_name          = tci.report_name,
    tc.encounter_type_uuid  = tci.encounter_type_uuid,
    tc.incremental_record   = 1
WHERE tc.table_json_data_hash <> tci.table_json_data_hash
  AND tc.table_json_data_hash IS NOT NULL;

-- If an encounter type has been voided then delete it from dim_json
DELETE
FROM mamba_flat_table_config
WHERE encounter_type_id NOT IN (SELECT tci.encounter_type_id FROM mamba_flat_table_config_incremental tci);

-- $END