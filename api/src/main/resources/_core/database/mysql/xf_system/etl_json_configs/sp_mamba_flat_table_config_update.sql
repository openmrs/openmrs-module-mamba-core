-- $BEGIN

-- Update the hash of the JSON data
UPDATE mamba_flat_table_config
SET table_json_data_hash = MD5(table_json_data)
WHERE id > 0;

-- $END