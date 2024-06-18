-- $BEGIN
DECLARE starttime DATETIME;
SELECT  start_time INTO starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_orders (order_id, uuid, order_type_id, concept_id, patient_id, encounter_id, accession_number,
                              order_number, orderer, instructions, date_activated, auto_expire_date, date_stopped,
                              order_reason, creator, date_created, voided, voided_by, date_voided, void_reason,
                              order_reason_non_coded, urgency, previous_order_id, order_action, comment_to_fulfiller,
                              care_setting, scheduled_date, order_group_id, sort_weight, fulfiller_comment,
                              fulfiller_status, flag)
SELECT
    order_id,
    uuid,
    order_type_id,
    concept_id,
    patient_id,
    encounter_id,
    accession_number,
    order_number,
    orderer,
    instructions,
    date_activated,
    auto_expire_date,
    date_stopped,
    order_reason,
    creator,
    date_created,
    voided,
    voided_by,
    date_voided,
    void_reason,
    order_reason_non_coded,
    urgency,
    previous_order_id,
    order_action,
    comment_to_fulfiller,
    care_setting,
    scheduled_date,
    order_group_id,
    sort_weight,
    fulfiller_comment,
    fulfiller_status,
    1  flag
FROM mamba_source_db.orders ord
WHERE ord.date_created >= starttime;


-- Update only modified records
UPDATE mamba_dim_orders o
    INNER JOIN mamba_source_db.orders ord
ON o.order_id = ord.order_id
    SET o.order_number = ord.order_number ,
        o.orderer = ord.orderer,
        o.instructions = ord.instructions,
        o.voided = ord.voided,
        o.voided_by = ord.voided_by,
        o.void_reason = ord.void_reason,
        o.fulfiller_comment = ord.fulfiller_comment,
        o.flag = 2
WHERE ord.date_changed >= starttime;



-- $END