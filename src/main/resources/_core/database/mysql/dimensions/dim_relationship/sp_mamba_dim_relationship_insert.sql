-- $BEGIN

INSERT INTO mamba_dim_relationship
    (
        relationship_id,
        person_a,
        relationship,
        person_b,
        start_date,
        end_date,
        creator,
        date_created,
        date_changed,
        changed_by,
        voided,
        voided_by,
        date_voided,
        void_reason,
        uuid
    )
SELECT
    relationship_id,
    person_a,
    relationship,
    person_b,
    start_date,
    end_date,
    creator,
    date_created,
    date_changed,
    changed_by,
    voided,
    voided_by,
    date_voided,
    void_reason,
    uuid
FROM relationship;

-- $END