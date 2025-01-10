-- $BEGIN
-- Delete any concept names that have become voided or not locale_preferred or not our locale we set
DELETE FROM mamba_dim_concept_name
WHERE voided <> 0
   OR locale_preferred <> 1
   OR locale COLLATE utf8mb4_general_ci NOT IN (
       SELECT DISTINCT(concepts_locale) COLLATE utf8mb4_general_ci 
       FROM _mamba_etl_user_settings
   );

-- $END