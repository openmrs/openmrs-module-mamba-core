-- $BEGIN
-- delete un wanted rows after inserting columns that were not given in the .json config file into the meta data table,
-- all rows with 'AUTO-GENERATE' are not used anymore. Delete them/1
DELETE
FROM mamba_concept_metadata
WHERE concept_uuid = 'AUTO-GENERATE'
  AND column_label = 'AUTO-GENERATE';

-- $END