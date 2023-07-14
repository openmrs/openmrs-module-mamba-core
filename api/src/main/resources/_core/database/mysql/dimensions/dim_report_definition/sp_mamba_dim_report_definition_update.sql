-- $BEGIN


SELECT (select cn.name
        from concept_name cn
        where cn.concept_id = o.value_coded
          and cn.locale = 'en'
          and cn.locale_preferred = 1) AS mother_hiv_status
FROM obs o
         INNER JOIN concept c ON o.concept_id = c.concept_id
WHERE c.uuid = '159427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
  AND o.encounter_id = (SELECT DISTINCT (e.encounter_id)
                        FROM obs o
                                 INNER JOIN concept c ON o.concept_id = c.concept_id
                                 inner join encounter e ON o.encounter_id = e.encounter_id
                                 INNER JOIN encounter_type et ON e.encounter_type = et.encounter_type_id
                                 INNER JOIN person p ON e.patient_id = p.person_id
                        WHERE o.value_text = '10000A2000005'
                          AND p.uuid = 'bc86e441-d54d-4da7-b5a9-9db64600b37d'
                          AND et.uuid = '2549af50-75c8-4aeb-87ca-4bb2cef6c69a'
                          AND o.voided = 0);

-- $END


