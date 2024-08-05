-- $BEGIN

-- update table_json_data_hash
UPDATE mamba_dim_json_incremental j
SET j.table_json_data_hash = MD5(table_json_data)
WHERE table_json_data IS NOT NULL;

-- If a new encounter type has been added
INSERT INTO mamba_dim_json (report_name, encounter_type_id, table_json_data, uuid, table_json_data_hash, flag)
SELECT j1.report_name,
       j1.encounter_type_id,
       j1.table_json_data,
       j1.uuid,
       j1.table_json_data_hash,
       1
FROM mamba_dim_json_incremental j1
WHERE j1.encounter_type_id NOT IN (SELECT encounter_type_id FROM mamba_dim_json);

-- If there is any change in either concepts or encounter types in terms of names or additional questions
UPDATE mamba_dim_json j
    INNER JOIN mamba_dim_json_incremental j1 ON j.encounter_type_id = j1.encounter_type_id
SET j.table_json_data_hash = j1.table_json_data_hash,
    j.report_name    = j1.report_name,
    j.uuid           = j1.uuid,
    j.flag           = 2
WHERE j.table_json_data_hash <> j1.table_json_data_hash
  AND j.table_json_data_hash IS NOT NULL;

-- If an encounter type has been voided then delete it from dim_json
DELETE
FROM mamba_dim_json
WHERE encounter_type_id NOT IN (SELECT encounter_type_id FROM mamba_dim_json_incremental);

-- $END