-- $BEGIN

CREATE TABLE mamba_dim_relationship
(
    relationship_id    INT           NOT NULL UNIQUE PRIMARY KEY,
    person_a           INT           NOT NULL,
    relationship       INT           NOT NULL,
    person_b           INT           NOT NULL,
    start_date         DATETIME      NULL,
    end_date           DATETIME      NULL,
    creator            INT           NOT NULL,
    uuid               CHAR(38)      NOT NULL,
    date_created       DATETIME      NOT NULL,
    date_changed       DATETIME      NULL,
    changed_by         INT           NULL,
    date_voided        DATETIME      NULL,
    voided             TINYINT(1)    NOT NULL,
    voided_by          INT           NULL,
    void_reason        VARCHAR(255)  NULL,
    incremental_record INT DEFAULT 0 NOT NULL,

    INDEX mamba_idx_person_a (person_a),
    INDEX mamba_idx_person_b (person_b),
    INDEX mamba_idx_relationship (relationship),
    INDEX mamba_idx_incremental_record (incremental_record)

) CHARSET = UTF8MB3;

-- $END
