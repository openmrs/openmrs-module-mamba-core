-- $BEGIN
-- Delete any concept names that have become voided or not locale_preferred or not our locale we set (so we are consistent with the original INSERT statement)
-- We only need to keep the non-voided, locale we set & locale_preferred concept names
-- This is because when concept names are modified, the old name is voided and a new name is created but both have a date_changed value of the same date (donno why)

DELETE
FROM mamba_dim_concept_name
WHERE voided <> 0
   OR locale_preferred <> 1
   OR locale NOT IN (SELECT DISTINCT(concepts_locale) FROM mamba_etl_user_settings);

-- $END