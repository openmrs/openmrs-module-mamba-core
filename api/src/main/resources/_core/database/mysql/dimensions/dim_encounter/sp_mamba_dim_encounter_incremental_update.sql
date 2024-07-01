-- $BEGIN

SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_encounter (encounter_id,
                                 uuid,
                                 encounter_type,
                                 encounter_type_uuid,
                                 patient_id,
                                 encounter_datetime,
                                 date_created,
                                 voided,
                                 visit_id,
                                 flag)
SELECT e.encounter_id,
       e.uuid,
       e.encounter_type,
       et.uuid,
       e.patient_id,
       e.encounter_datetime,
       e.date_created,
       e.voided,
       e.visit_id,
       1 flag
FROM mamba_source_db.encounter e
         INNER JOIN mamba_dim_encounter_type et
                    ON e.encounter_type = et.encounter_type_id
WHERE  e.date_created >= @starttime;

-- Update only modified records
UPDATE mamba_dim_encounter e
    INNER JOIN mamba_source_db.encounter enc
ON e.encounter_id = enc.encounter_id
    INNER JOIN mamba_dim_encounter_type et
ON enc.encounter_type = et.encounter_type_id
    SET e.uuid = enc.uuid ,
        e.encounter_type = enc.encounter_type,
        e.encounter_type_uuid = et.uuid,
        e.encounter_datetime = enc.encounter_datetime,
        e.voided = enc.voided,
        e.visit_id = enc.visit_id,
        e.flag = 2
WHERE enc.date_changed >= @starttime;

-- $END