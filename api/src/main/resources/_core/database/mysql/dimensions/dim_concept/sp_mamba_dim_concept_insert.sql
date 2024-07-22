-- $BEGIN

INSERT INTO mamba_dim_concept (uuid,
                               concept_id,
                               datatype_id,
                               retired,
                               date_created,
                               date_changed,
                               changed_by,
                               date_retired,
                               retired_by,
                               retire_reason)
SELECT c.uuid          AS uuid,
       c.concept_id    AS concept_id,
       c.datatype_id   AS datatype_id,
       c.retired       AS retired,
       c.date_created  AS date_created,
       c.date_changed  AS date_changed,
       c.changed_by    AS changed_by,
       c.date_retired  AS date_retired,
       c.retired_by    AS retired_by,
       c.retire_reason AS retire_reason
FROM mamba_source_db.concept c;

-- $END