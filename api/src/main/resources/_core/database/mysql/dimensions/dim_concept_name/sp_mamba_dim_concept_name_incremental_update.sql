-- $BEGIN

SELECT  start_time INTO @starttime
FROM _mamba_etl_schedule sch
WHERE end_time IS NOT NULL
  AND transaction_status ='COMPLETED'
ORDER BY id DESC
    LIMIT 1;

-- Insert only new records
INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    name,
                                    locale,
                                    locale_preferred,
                                    voided,
                                    concept_name_type,
                                    flag)
SELECT cn.concept_name_id,
       cn.concept_id,
       cn.name,
       cn.locale,
       cn.locale_preferred,
       cn.voided,
       cn.concept_name_type,
       1 flag
FROM mamba_source_db.concept_name cn
WHERE cn.locale IN (SELECT DISTINCT(locale) FROM mamba_dim_locale)
  AND cn.locale_preferred = 1
  AND cn.voided = 0 AND cn.date_created >= @starttime;

-- Update only modified records
UPDATE mamba_dim_concept_name cn
    INNER JOIN mamba_source_db.concept_name cnm
ON cn.concept_name_id = cnm.concept_name_id
SET cn.concept_id = cnm.concept_id ,
    cn.name = cnm.name,
    cn.locale = cnm.locale,
    cn.locale_preferred = cnm.locale_preferred,
    cn.voided = cnm.voided,
    cn.concept_name_type = cnm.concept_name_type,
    cn.flag = 2
WHERE cnm.date_changed >= @starttime;

-- $END