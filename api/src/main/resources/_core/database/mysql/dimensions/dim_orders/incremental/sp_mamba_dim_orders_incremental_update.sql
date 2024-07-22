-- $BEGIN

SELECT start_time
INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status = 'COMPLETED'
ORDER BY id DESC
LIMIT 1;

-- Modified Encounters
UPDATE mamba_dim_orders do
    INNER JOIN mamba_source_db.orders o
    ON o.order_id = do.order_id
SET do.order_id               = o.order_id,
    do.uuid                   = o.uuid,
    do.order_type_id          = o.order_type_id,
    do.concept_id             = o.concept_id,
    do.patient_id             = o.patient_id,
    do.encounter_id           = o.encounter_id,
    do.accession_number       = o.accession_number,
    do.order_number           = o.order_number,
    do.orderer                = o.orderer,
    do.instructions           = o.instructions,
    do.date_activated         = o.date_activated,
    do.auto_expire_date       = o.auto_expire_date,
    do.date_stopped           = o.date_stopped,
    do.order_reason           = o.order_reason,
    do.order_reason_non_coded = o.order_reason_non_coded,
    do.urgency                = o.urgency,
    do.previous_order_id      = o.previous_order_id,
    do.order_action           = o.order_action,
    do.comment_to_fulfiller   = o.comment_to_fulfiller,
    do.care_setting           = o.care_setting,
    do.scheduled_date         = o.scheduled_date,
    do.order_group_id         = o.order_group_id,
    do.sort_weight            = o.sort_weight,
    do.fulfiller_comment      = o.fulfiller_comment,
    do.fulfiller_status       = o.fulfiller_status,
    do.date_created           = o.date_created,
    do.creator                = o.creator,
    do.voided                 = o.voided,
    do.voided_by              = o.voided_by,
    do.date_voided            = o.date_voided,
    do.void_reason            = o.void_reason,
    do.incremental_record     = 1
WHERE o.voided = 1
  AND o.date_voided >= @starttime;

-- $END