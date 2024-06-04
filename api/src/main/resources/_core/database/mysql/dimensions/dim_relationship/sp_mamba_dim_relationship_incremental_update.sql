-- $BEGIN
-- Insert only new records
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
    uuid,
    flag)
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
    uuid,
    1  flag
FROM mamba_source_db.relationship r
WHERE r.date_created >= '2023-11-30 00:00:00';


-- Update only modified records
UPDATE mamba_dim_relationship r
    INNER JOIN mamba_source_db.relationship rel
ON r.user_id = rel.user_id
    SET r.relationship = rel.relationship ,
        r.person_a = rel.person_a,
        r.person_b = rel.person_b,
        r.date_changed = rel.date_changed,
        r.changed_by = rel.changed_by,
        r.flag = 2
WHERE us.date_changed >= '2023-11-30 00:00:00';



-- $END