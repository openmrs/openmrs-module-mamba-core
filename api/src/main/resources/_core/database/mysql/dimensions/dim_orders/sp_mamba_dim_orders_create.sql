-- $BEGIN

CREATE TABLE mamba_dim_orders
(
    id                     INT           NOT NULL AUTO_INCREMENT,
    order_id               INT           NOT NULL,
    uuid                   CHAR(38)      NOT NULL,
    order_type_id          INT           NOT NULL,
    concept_id             INT           NOT NULL,
    patient_id             INT           NOT NULL,
    encounter_id           INT           NOT NULL, -- links with encounter table
    accession_number       VARCHAR(255)  NULL,
    order_number           VARCHAR(50)   NOT NULL,
    orderer                INT           NOT NULL,
    instructions           TEXT          NULL,
    date_activated         DATETIME      NULL,
    auto_expire_date       DATETIME      NULL,
    date_stopped           DATETIME      NULL,
    order_reason           INT           NULL,
    order_reason_non_coded VARCHAR(255)  NULL,
    urgency                VARCHAR(50)   NOT NULL,
    previous_order_id      INT           NULL,
    order_action           VARCHAR(50)   NOT NULL,
    comment_to_fulfiller   VARCHAR(1024) NULL,
    care_setting           INT           NOT NULL,
    scheduled_date         DATETIME      NULL,
    order_group_id         INT           NULL,
    sort_weight            DOUBLE        NULL,
    fulfiller_comment      VARCHAR(1024) NULL,
    fulfiller_status       VARCHAR(50)   NULL,
    date_created           DATETIME      NOT NULL,
    creator                INT           NULL,
    voided                 TINYINT(1)    NOT NULL,
    voided_by              INT           NULL,
    date_voided            DATETIME      NULL,
    void_reason            VARCHAR(255)  NULL,
    incremental_record     INT DEFAULT 0 NOT NULL,

    PRIMARY KEY (id)
)
    CHARSET = UTF8MB4;

CREATE INDEX mamba_dim_orders_order_id_index
    ON mamba_dim_orders (order_id);

CREATE INDEX mamba_dim_orders_uuid_index
    ON mamba_dim_orders (uuid);

CREATE INDEX mamba_dim_orders_order_type_id_index
    ON mamba_dim_orders (order_type_id);

CREATE INDEX mamba_dim_orders_concept_id_index
    ON mamba_dim_orders (concept_id);

CREATE INDEX mamba_dim_orders_patient_id_index
    ON mamba_dim_orders (patient_id);

CREATE INDEX mamba_dim_orders_encounter_id_index
    ON mamba_dim_orders (encounter_id);

CREATE INDEX mamba_dim_orders_incremental_record_index
    ON mamba_dim_orders (incremental_record);

-- $END
