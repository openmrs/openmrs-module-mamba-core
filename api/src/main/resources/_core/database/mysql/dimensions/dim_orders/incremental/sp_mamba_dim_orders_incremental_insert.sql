-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_orders (order_id,
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
                              date_created,
                              creator,
                              voided,
                              voided_by,
                              date_voided,
                              void_reason,
                              incremental_record)
SELECT order_id,
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
       date_created,
       creator,
       voided,
       voided_by,
       date_voided,
       void_reason,
       1
FROM mamba_source_db.orders ord
WHERE ord.order_id NOT IN (SELECT DISTINCT (order_id) FROM mamba_dim_orders)
  AND ord.date_created >= @starttime;

-- $END