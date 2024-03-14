-- $BEGIN

INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    name,
                                    locale,
                                    locale_preferred,
                                    voided,
                                    concept_name_type)
SELECT cn.concept_name_id,
       cn.concept_id,
       cn.name,
       cn.locale,
       cn.locale_preferred,
       cn.voided,
       cn.concept_name_type
FROM mamba_source_db.concept_name cn
 WHERE cn.locale = 'en'
  AND cn.locale_preferred = 1
    AND cn.voided = 0;

-- $END