-- $BEGIN

UPDATE mamba_dim_encounter_type et
SET et.auto_flat_table_name = LOWER(LEFT(
        REPLACE(REPLACE(fn_mamba_remove_special_characters(CONCAT('mamba_flat_encounter_', et.name)), ' ', '_'), '__',
                '_'), 60))
WHERE et.encounter_type_id > 0;

-- $END