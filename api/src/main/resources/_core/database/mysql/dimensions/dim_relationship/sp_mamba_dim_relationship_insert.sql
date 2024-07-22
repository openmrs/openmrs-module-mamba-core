-- $BEGIN

INSERT INTO mamba_dim_relationship(relationship_id,
                                   person_a,
                                   relationship,
                                   person_b,
                                   start_date,
                                   end_date,
                                   creator,
                                   uuid,
                                   date_created,
                                   date_changed,
                                   changed_by,
                                   voided,
                                   voided_by,
                                   date_voided,
                                   void_reason)
SELECT relationship_id,
       person_a,
       relationship,
       person_b,
       start_date,
       end_date,
       creator,
       uuid,
       date_created,
       date_changed,
       changed_by,
       voided,
       voided_by,
       date_voided,
       void_reason
FROM mamba_source_db.relationship;

-- $END