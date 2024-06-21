-- $BEGIN
DECLARE starttime DATETIME;
SELECT  start_time INTO starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_encounter_type (encounter_type_id,
                                      uuid,
                                      name,
                                      flag)
SELECT et.encounter_type_id,
       et.uuid,
       et.name,
       1 flag
FROM mamba_source_db.encounter_type et
WHERE et.date_created >= starttime;

-- Update only modified records
UPDATE mamba_dim_encounter_type et
    INNER JOIN mamba_source_db.encounter_type ent
ON e.encounter_type_id = ent.encounter_id
    SET et.uuid = ent.uuid ,
        et.name = ent.name,
        et.flag = 2
WHERE ent.date_changed >= starttime;

-- $END