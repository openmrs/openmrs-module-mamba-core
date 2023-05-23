-- $BEGIN

INSERT INTO mamba_dim_concept_name (concept_name_id,
                                    concept_id,
                                    concept_name)
SELECT cn.concept_name_id AS concept_name_id,
       cn.concept_id      AS concept_id,
       cn.name            AS concept_name
FROM concept_name cn;
-- WHERE cn.locale = 'en'
--  AND cn.locale_preferred = 1;

-- $END
