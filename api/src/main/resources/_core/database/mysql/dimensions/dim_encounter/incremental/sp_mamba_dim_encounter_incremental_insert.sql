-- $BEGIN

-- Insert only new records
INSERT INTO mamba_dim_encounter (encounter_id,
                                 uuid,
                                 encounter_type,
                                 encounter_type_uuid,
                                 patient_id,
                                 visit_id,
                                 encounter_datetime,
                                 date_created,
                                 date_changed,
                                 changed_by,
                                 date_voided,
                                 voided,
                                 voided_by,
                                 void_reason,
                                 incremental_record)
SELECT e.encounter_id,
       e.uuid,
       e.encounter_type,
       et.uuid,
       e.patient_id,
       e.visit_id,
       e.encounter_datetime,
       e.date_created,
       e.date_changed,
       e.changed_by,
       e.date_voided,
       e.voided,
       e.voided_by,
       e.void_reason,
       1
FROM mamba_source_db.encounter e
         INNER JOIN mamba_etl_incremental_columns_index_new ic
                    ON e.encounter_type = ic.incremental_table_pkey
         INNER JOIN mamba_dim_encounter_type et
                    ON e.encounter_type = et.encounter_type_id
WHERE et.uuid
          IN (SELECT DISTINCT(md.encounter_type_uuid)
              FROM mamba_concept_metadata md);
-- $END