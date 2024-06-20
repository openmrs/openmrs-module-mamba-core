-- $BEGIN
-- update Json_data_hash
UPDATE mamba_dim_json_incremental j
SET j.Json_data_hash = MD5(Json_data)
WHERE Json_data IS NOT NULL;


-- $END