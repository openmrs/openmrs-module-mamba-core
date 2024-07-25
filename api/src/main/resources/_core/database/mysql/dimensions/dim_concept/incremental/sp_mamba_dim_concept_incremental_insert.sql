-- $BEGIN

-- Insert only new Records
INSERT INTO mamba_dim_concept (concept_id,
                               uuid,
                               datatype_id,
                               retired,
                               date_created,
                               date_changed,
                               changed_by,
                               date_retired,
                               retired_by,
                               retire_reason,
                               incremental_record)
SELECT c.concept_id    AS concept_id,
       c.uuid          AS uuid,
       c.datatype_id   AS datatype_id,
       c.retired       AS retired,
       c.date_created  AS date_created,
       c.date_changed  AS date_changed,
       c.changed_by    AS changed_by,
       c.date_retired  AS date_retired,
       c.retired_by    AS retired_by,
       c.retire_reason AS retire_reason,
       1
FROM mamba_source_db.concept c
         INNER JOIN mamba_etl_incremental_columns_index_new ic
                    ON c.concept_id = ic.incremental_table_pkey;

-- $END